# MacBook migration runbook

Moving to a new MacBook, carrying only what cannot be reproduced. **Not** a
Migration Assistant transfer; the old machine has years of dead AI-tool dirs
(`.aider`, `.kiro`, `.copilot`, `.gemini`, `.opencode`, `.antigravity`,
`.cursor`) that should not follow.

The old machine stays online as a fallback, so anything missed can be pulled
later. Nothing here is destructive on the old machine.

**Old machine:** `Bestija-v4.local` (LAN `192.168.1.23`), user `stef`.
Set `OLD=stef@Bestija-v4.local` in every shell below.

Steps marked **[HUMAN]** need a password, a browser, or a GUI. Everything else
Claude can run unattended with Bash.

---

## Step 0 — on the OLD machine [HUMAN]

SSH is off by default. Turn on Remote Login:

```bash
sudo systemsetup -setremotelogin on
```

Verify it is listening:

```bash
lsof -nP -iTCP:22 -sTCP:LISTEN
```

Both machines must be on the same Wi-Fi for the `.local` name to resolve.
If Bonjour misbehaves, use `192.168.1.23` instead.

Turn Remote Login back off once the migration is done.

---

## Step 1 — new machine prereqs [HUMAN]

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install rsync git gh
```

Then start `claude` and hand it this file. Password prompts for rsync are
expected on every command until Step 3 installs the ssh config.

---

## Step 2 — Tier 1: irreplaceable

Exists nowhere but the old disk. Under 5 MB total. Do `.ssh` first; nothing
else works without it.

```bash
OLD=stef@Bestija-v4.local
```

### 2a. SSH keys

```bash
rsync -av $OLD:.ssh/ ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa ~/.ssh/config
```

Sanity check: `ssh -T git@github.com` should greet you by username.

### 2b. Live API tokens

`~/.zshenv` is where the real token values live. `list-secrets.mjs` reports
six of them as "env only, not in keychain", meaning this file is their only
copy on disk.

```bash
rsync -av $OLD:.zshenv ~/
chmod 600 ~/.zshenv
```

### 2c. Claude config and local skills

`~/.claude/skills` holds ~30 skills that are not in any marketplace plugin.

```bash
mkdir -p ~/.claude
rsync -av $OLD:'.claude/{settings.json,CLAUDE.md,keybindings.json,mcp.json,local-dev-servers.md,statusline-command.sh,workspace.md,telemetry.env}' ~/.claude/
rsync -av $OLD:'.claude/{hooks,agents,commands,output-styles,skills}' ~/.claude/
chmod +x ~/.claude/statusline-command.sh ~/.claude/hooks/* 2>/dev/null
```

Optional, saves re-adding MCP servers by hand. The file is ~400 KB and mixes
in session cruft, so skip it if you would rather start clean:

```bash
rsync -av $OLD:.claude.json ~/
```

### 2d. Claude memory

30 accumulated feedback rules, not in any git repo.

```bash
mkdir -p ~/.claude/projects/-Users-stef-dev-productive-work
rsync -av $OLD:'.claude/projects/-Users-stef-dev-productive-work/memory' \
  ~/.claude/projects/-Users-stef-dev-productive-work/
```

### 2e. Workspace state

Requires the `work` repo from Step 4a to exist first, or just create the dir.
`workspaces/` and `knowledge/me.md` are both gitignored, so they are local-only.

The excludes drop the checked-out repo worktrees (gigabytes, all
reproducible) while keeping `workspace.md`, the notes, `output/`, `Caddyfile`,
`Procfile`, `.tmuxinator.yml`, and the local-only notes git repo in each
workspace root.

```bash
mkdir -p ~/dev/productive/work/workspaces
rsync -av \
  --exclude='/*/api/' --exclude='/*/frontend/' --exclude='/*/ai-agent/' \
  --exclude='/*/backoffice/' --exclude='/*/devportal/' --exclude='/*/logs/' \
  $OLD:dev/productive/work/workspaces/ ~/dev/productive/work/workspaces/

rsync -av $OLD:dev/productive/work/knowledge/me.md ~/dev/productive/work/knowledge/
```

### 2f. Caddy routing table

35 `reverse_proxy` blocks, one per worktree hostname. Pulled to a temp path
because a fresh `brew install caddy` writes its own default Caddyfile; merge
by hand rather than clobbering.

```bash
rsync -av $OLD:/opt/homebrew/etc/Caddyfile /tmp/Caddyfile.old
```

### 2g. Configs chezmoi does NOT manage

chezmoi covers `alacritty`, `ghostty`, and `nvim` under `~/.config`, plus the
`home/` dotfiles. Everything below is outside it.

```bash
rsync -av $OLD:'.config/{herdr,workspaces,w,gh,git,keyboardcowboy,atuin}' ~/.config/
rsync -av $OLD:.local/share/atuin ~/.local/share/
rsync -av $OLD:.tool-versions ~/
```

`~/.local/share/atuin` is 6 MB: 2023 shell-history entries plus the `key` file
that sync is keyed on. `zsh/tools.zsh` initializes atuin as your Ctrl+R, so it
is in the Brewfile.

`~/.config/herdr/agent-detection/` holds local rules that shadow upstream;
they are the reason herdr reports agent state correctly.

`~/.tool-versions` pins 9 runtimes and is not chezmoi-managed, so it has to be
copied. See Step 3b.

### 2h. Personal CLIs

`~/.local/bin` holds `workspaces`, `w-popup`, `ov-popup`, `pr-popup`, `agent`,
and the `tb-*` family. `--no-links` skips the symlinks that point into
`~/.local/share` (those tools get reinstalled in Step 5).

Delete `~/.local/bin/saggar` afterwards; it was a trial and is not in use.

```bash
mkdir -p ~/.local/bin
rsync -av --no-links $OLD:.local/bin/ ~/.local/bin/
chmod +x ~/.local/bin/*
```

### 2i. GUI app state

The Brewfile installs the apps; it carries none of their settings. Only two
apps hold state worth moving, and both also hold a license file.

**Quit both apps on the old machine first.** macOS caches plist writes in
`cfprefsd`, so copying a running app's preferences can capture a stale file.

TablePlus — saved connections, groups, favorites, query history, license:

```bash
TP="Library/Application Support/com.tinyapp.TablePlus"
mkdir -p ~/"$TP"
rsync -av $OLD:"$TP/Data" $OLD:"$TP/.licensemac" ~/"$TP/"
rsync -av $OLD:Library/Preferences/com.tinyapp.TablePlus.plist ~/Library/Preferences/
```

Connection *passwords* live in the login Keychain, not in these files, so they
do not come across. Re-enter them on first connect.

Alfred — workflows, snippets, settings, Powerpack license. `Databases/` is
61 MB of clipboard history and is deliberately skipped:

```bash
AL="Library/Application Support/Alfred"
mkdir -p ~/"$AL"
rsync -av $OLD:"$AL/Alfred.alfredpreferences" $OLD:"$AL/Automation" \
          $OLD:"$AL/prefs.json" $OLD:"$AL"/powerpack.*.dat ~/"$AL/"
```

### 2j. Zen Browser profile

The `zen` cask comes from the Brewfile. The profile does not, and it is 4.0 GB
across two profiles; the active one is `ei91s0r8.Default (alpha)`, named in
`profiles.ini`.

**Quit Zen first**, or the sqlite files copy mid-write.

Sign into Firefox Sync on the new machine for bookmarks, history, passwords,
open tabs and extensions. Sync does **not** carry Zen's own settings, so copy
those by hand. This skips `storage/`, which is 3.3 GB of the 3.7 GB:

```bash
Z="Library/Application Support/zen/Profiles/ei91s0r8.Default (alpha)"
mkdir -p ~/"$Z"
rsync -av $OLD:"$Z/prefs.js" $OLD:"$Z/containers.json" \
          $OLD:"$Z/zen-themes.css" $OLD:"$Z/zen-keyboard-shortcuts.json" \
          $OLD:"$Z/zen-themes" $OLD:"$Z/zen-sessions-backup" ~/"$Z/"
rsync -av $OLD:Library/Application\ Support/zen/profiles.ini ~/Library/Application\ Support/zen/
```

`zen-sessions-backup` (52 MB) is what holds your workspaces and split views.
Drop it if you would rather start clean.

If you would rather not use Sync, `logins.json` carries saved passwords but is
useless without `key4.db` from the same profile — copy both or neither.

Copying the whole profile also works and preserves every logged-in web session,
but it is 3.7 GB and brings `favicons.sqlite` (59 MB), `gmp-widevinecdm` and
sync WAL files that all regenerate on their own.

### 2k. Apps with nothing worth carrying

Install and move on. Gitify's 52 MB is Electron cache behind a single OAuth
token, so log in again. 1Password, Slack and Chrome all restore from their
accounts. Ghostty config comes from the dotfiles repo, and Keyboard Cowboy's
from `~/.config/keyboardcowboy` in Step 2g.

Dropped rather than migrated: Hammerspoon (Keyboard Cowboy replaced it; it was
not even running on the old machine) and VS Code. `~/.hammerspoon` still holds
`workspace-hud.lua`, 20 KB of real work, if you ever want it back — it is on
the old machine, which stays online.

---

## Step 3 — dotfiles

### 3a. Push from the old machine first [HUMAN]

**This is the highest-risk step in the migration.** The dotfiles repo on
GitHub is missing 14 load-bearing files that were never committed. Cloning it
as-is gives you a machine with no login shell, no prompt, no PATH, no aliases,
and no Ghostty config.

Never committed:

| path | what breaks without it |
|---|---|
| `home/zprofile` + `symlink_dot_zprofile.tmpl` | entire login shell: PATH, mise, mysql-client, `load-secrets.sh`, `load-otel.sh` |
| `home/zsh/{path,plugins,prompt,tools}.zsh` | prompt, plugins, PATH, tool init |
| `home/zsh/aliases/main.zsh` | every alias |
| `dot_zsh/symlink_{path,plugins,prompt,tools}.zsh.tmpl` | the symlinks that wire the above in |
| `home/config/ghostty/` + `dot_config/symlink_ghostty.tmpl` | terminal config |
| `home/config/nvim/lua/plugins/review.lua` | review.nvim, how you read diffs |

Also modified and unpushed: nvim config (13 files), `zshrc`, `gitconfig`,
`gitignore`, `tmux.conf`, `tmux/theme.tmux`, `Brewfile`.

`home/warp/settings.toml` is untracked too; Warp was dropped from the Brewfile,
so leave it out.

This is config, not half-finished code. It has to be committed and pushed; the
unfinished worktree changes in Appendix A are a separate matter and stay
uncommitted.

Do **not** run `brew bundle dump`. `home/Brewfile` is hand-curated with
section comments and deliberately excludes ~25 installed packages; a dump
would flatten it and drag the junk along. It was already reviewed and updated
for this migration: `git-delta` name fix, `mise` in place of `asdf`, added
`caddy` / `overmind` / `vpnutil` / `herdr` / `libpq` / `redis` /
`1password-cli` / `ghostty` / `session-manager-plugin`, dropped `gnupg` and
`warp` and the four dead `tap` lines.

```bash
cd ~/.dotfiles
git add -A && git commit -m "sync before machine migration" && git push
```

### 3b. Install on the new machine

```bash
brew install chezmoi
git clone git@github.com:d4be4st/dotfiles ~/.dotfiles
~/.dotfiles/install
brew bundle install --file=~/.dotfiles/home/Brewfile
```

**Runtimes are on mise now, not asdf.** `zprofile` activates mise and
`~/.tool-versions` (copied in Step 2g) is read as-is. Two of its entries use
asdf plugin names; mise's canonical names are `node` and `go`:

```
nodejs 25.8.1   ->  node 25.8.1
golang 1.26.2   ->  go 1.26.2
```

mise aliases both, but rename them to be safe. Then:

```bash
mise install     # python 3.12.5, ruby 3.4.1, node, erlang, elixir, bun, gleam, go, rust
mise doctor
```

Do not copy `~/.asdf`; it is dead, and its shims are already broken on the old
machine.

`~/.zprofile` sources `load-secrets.sh` and `load-otel.sh` from the `work`
repo, so those paths must exist (Step 4a) before a new shell is clean.

---

## Step 4 — Tier 3: reproducible, do not copy

### 4a. Repos

```bash
mkdir -p ~/dev/productive
git clone git@github.com:productiveio/work.git ~/dev/productive/work
cd ~/dev/productive/work && ./scripts/repo-sync.sh
```

### 4b. Claude plugins

542 MB on the old machine. Reinstall from the marketplace instead:

```
/plugin install p-dev@productive
```

Then the rest from `knowledge/tooling/claude-plugins.md`.

### 4c. Session transcripts

`~/.claude/projects` is 386 MB of past session history. Only worth pulling if
you want `tb-session` search over old work, and the old machine stays online
for that anyway. Skip by default.

### 4d. Local Docker infrastructure

Nothing here is carried. The old machine had ~49 GB of Docker state (17.4 GB
images, 29.5 GB volumes, 2.1 GB build cache) and all of it rebuilds: images
re-pull, `*-gems-data` and `*-node_modules-data` volumes are just bundle and
npm caches, and the meilisearch volumes (6 GB across two) are reindexed.

Compose lives in `productiveio/local-development`, cloned to a folder named
`docker` rather than `local-development`. Build contexts are relative
(`context: ../api`), so keep the sibling layout under `~/dev/productive/`:
`api`, `app`, `mailer`, `realtime`, `docs-realtime`, `exporter`, `polaris`.

OrbStack comes from the Brewfile in Step 3b, so it is already installed.

```bash
git clone git@github.com:productiveio/local-development.git ~/dev/productive/docker
cd ~/dev/productive/docker
docker compose up -d mysql mysql-test redis memcached postgres meilisearch
```

Those six support services are what actually runs day to day; the app services
in the compose file are not used, since apps run from workspaces via
`ov resume`. `postgres` is only there for polaris, which is why its volume was
by far the biggest thing on the old disk.

Manage it afterwards with the `tb-devctl` skill rather than raw compose.

**Ignore the README's `/etc/hosts` advice.** `*.productive.io.localhost`
resolves to loopback natively on macOS (RFC 6761) and Caddy already fronts
these hostnames. Do not add entries; see `~/.claude/local-dev-servers.md`.

Databases start empty. Re-seed however the team does it now rather than
copying volumes across.

---

## Step 5 — must re-login, cannot be copied [HUMAN]

- [ ] `gh auth login`
- [ ] `claude` login
- [ ] `aws sso login` (check `~/.aws/config` came over, or rsync it)
- [ ] Productive VPN profile (NE VPN, reinstall the profile; `vpnutil` drives it after)
- [ ] `sudo caddy trust` (installs the local CA so `*.productive.io.localhost` HTTPS is clean)
- [ ] Keychain: `node ~/dev/productive/work/scripts/setup-keychain.mjs`
      Two real entries on the old machine: `PRODUCTIVE_CLAUDE_ALLOY_USERNAME`
      and `PRODUCTIVE_CLAUDE_ALLOY_PASSWORD`.
- [ ] Reinstall vendored CLIs whose symlinks were skipped, only the ones you
      still want: `uv`, `cursor-agent`. (`aider`, `posting`, `specify` were
      trials.)
- [ ] 1Password, Chrome profile, Ghostty/Alacritty as apps (these are normal
      app installs, not config)

---

## Step 6 — verify

```bash
ssh -T git@github.com                                   # auth works
mise ls                                                  # 9 runtimes, no missing
node ~/dev/productive/work/scripts/list-secrets.mjs     # 8 found, matching old machine
brew services list | grep -w caddy                      # started
curl -k -I https://api.productive.io.localhost/          # route resolves
workspaces list                                          # 20 workspaces + inbox
ls ~/.claude/skills | wc -l                              # ~30
ls ~/.claude/projects/-Users-stef-dev-productive-work/memory | wc -l   # 30
```

---

## Appendix A — unfinished work, pulled on demand

Six worktrees had uncommitted working-tree changes at planning time. Nothing
was unpushed, so no commits are at risk. These are deliberately **not**
committed; they are half-finished.

| workspace | repo | dirty files |
|---|---|---|
| `backyard-meilisearch-api` | api | 20 |
| `spec-first-test-refactor` | api | 14 |
| `delta-sync-filter-changed-records-after-timestamp` | api | 10 |
| `update-event-doesn-t-update-notetaker` | frontend | 4 |
| `flag-detail-page-redesign-commit-consoli` | api | 1 |
| `flag-detail-page-redesign-commit-consoli` | backoffice | 1 |

Five of the six are paused. When you actually resume one, recreate its
worktree normally, then overlay the working tree from the old machine:

```bash
SLUG=spec-first-test-refactor
REPO=api
rsync -av --exclude='.git' --exclude='node_modules' --exclude='tmp' --exclude='log' \
  $OLD:dev/productive/work/workspaces/$SLUG/$REPO/ \
  ~/dev/productive/work/workspaces/$SLUG/$REPO/
```

Check `git status` in the worktree afterwards and confirm the diff matches
what the old machine showed.

---

## Appendix B — deliberately left behind

**Rebuilt by a later step, not copied:** Docker images, volumes and build
cache (~49 GB, Step 4d); every git clone under `~/dev/productive/` (Steps 4a
and 4d re-clone what's needed); `~/.claude/plugins` (542 MB, Step 4b);
`node_modules` anywhere.

**Dead tooling:** `~/.asdf` (replaced by mise; its shims are already broken on
the old machine), `~/.env` (stale `OPENROUTER_API_KEY` from the aider era),
`~/.aider*`, `~/.kiro`, `~/.copilot`, `~/.gemini`, `~/.opencode`,
`~/.antigravity`, `~/.cursor`, `~/.agent-os`, `~/.claudecodebrowser`,
`~/.ollama`, and everything peon-ping (brew formula, tap, `skills/peon-ping-*`,
`hooks/peon-ping/`).

**GUI app caches:** `Alfred/Databases` (61 MB clipboard history), Gitify's
52 MB of Electron cache, TablePlus `Cache/` and `Temp/`, VS Code extensions,
and the Zen profile's `storage/` (3.3 GB), `favicons.sqlite`,
`gmp-widevinecdm` and sync WAL files, plus the stale `77i7c0e5.default`
profile (376 MB).

**Churn and history:** `~/.claude.json.tmp.*`, `~/.claude/projects` (386 MB),
`~/.claude/{cache,debug,downloads,paste-cache,shell-snapshots,sessions,session-data}`,
`~/dev/worktrees` and `~/dev/productive/worktrees` (all four clean and merged),
`~/dev/productive/db_backup` (268 MB of seed dumps).
