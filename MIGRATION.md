# MacBook migration runbook

Rewritten 2026-09-03, straight after running it (Bestija-v4 to Bestija-v6).
Every correction from that run is baked in; the numbers in Step 6 are what a
finished machine actually reported, not what the previous draft guessed.

Carry only what cannot be reproduced. **Not** a Migration Assistant transfer:
the old disk accumulates dead AI-tool dirs (`.aider`, `.kiro`, `.copilot`,
`.gemini`, `.opencode`, `.antigravity`, `.cursor`, `.claudecodebrowser`) that
should not follow.

The old machine stays online as a fallback, so anything missed can be pulled
later. Nothing here is destructive on the old machine.

Set this in every shell below, filling in the old machine's name:

```bash
OLD=stef@<old-host>.local     # e.g. stef@Bestija-v4.local
```

Steps marked **[HUMAN]** need a password, a browser, or a GUI. Everything else
Claude can run unattended with Bash.

**Order that worked:** Step 0, 1, 2a-2c, then **Zen (2j) early** so you have a
working browser with your logins for every OAuth step that follows. The rest
in order after that.

---

## Step 0 — on the OLD machine [HUMAN]

1. Commit and push everything that is config, not half-finished code:

   ```bash
   cd ~/.dotfiles && git status --short     # expect clean before you leave
   git add -A && git commit -m "sync before machine migration" && git push
   ```

   Last time this repo was missing 14 load-bearing uncommitted files (zprofile,
   the whole `home/zsh/` tree, aliases, ghostty config, `review.lua`). Cloning
   it as-is would have given a machine with no login shell, no prompt, no PATH.
   **Check `git status` here before anything else.** Half-finished worktree
   changes are a separate matter and stay uncommitted (Appendix A).

2. Turn on Remote Login (off by default):

   ```bash
   sudo systemsetup -setremotelogin on
   lsof -nP -iTCP:22 -sTCP:LISTEN     # confirm it is listening
   ```

3. Note the LAN IP (`ipconfig getifaddr en0`). Both machines on the same
   Wi-Fi for `.local` to resolve; use the raw IP if Bonjour misbehaves.

4. **Quit Zen and TablePlus.** Their sqlite files and plists copy mid-write
   otherwise, and macOS caches plist writes in `cfprefsd`.

5. Do **not** run `brew bundle dump`. `home/Brewfile` is hand-curated with
   section comments and deliberately excludes ~25 installed packages. Review it
   by hand instead.

Remote Login goes back off in Step 7.

---

## Step 1 — new machine prereqs [HUMAN]

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install rsync git gh
curl -fsSL https://claude.ai/install.sh | bash     # PATH: ~/.local/bin
```

Name the machine and turn the firewall on:

```bash
sudo scutil --set ComputerName "Bestija-vN" \
  && sudo scutil --set LocalHostName "Bestija-vN" \
  && sudo scutil --set HostName "Bestija-vN"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

Generate a fresh key and push it to the old machine, so every rsync below runs
without a password prompt:

```bash
ssh-keygen -t ed25519 -a 100 -C "stef@Bestija-vN" -f ~/.ssh/id_ed25519 \
  && ssh-add --apple-use-keychain ~/.ssh/id_ed25519
ssh-copy-id -i ~/.ssh/id_ed25519.pub $OLD
```

Then start `claude` and hand it this file.

> **Gotcha hit last time:** ssh multiplexing fails with `ControlPath too long
> (… >= 104 bytes)` if the socket lands in Claude's scratchpad path. Run ssh
> from `~` or pass `-o ControlPath=~/.ssh/cm-%C`.

---

## Step 2 — Tier 1: irreplaceable

Exists nowhere but the old disk. Under 5 MB total, minus Zen. Do `.ssh` first;
nothing else works without it.

### 2a. SSH keys

```bash
rsync -av $OLD:.ssh/ ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa ~/.ssh/config
```

Sanity check: `ssh -T git@github.com` greets you by username.

### 2b. Tokens — check before copying

`~/.zshenv` holds raw token values. **Last time every one of them was already
revoked, so it was skipped entirely.** Read it first, keep only what is still
live, and prefer the keychain (Step 5) over a plaintext file:

```bash
ssh $OLD 'cat .zshenv'          # inspect, do not blind-copy
```

### 2c. Claude config and local skills

`~/.claude/skills` holds skills that are not in any marketplace plugin (24 on
the finished machine).

```bash
mkdir -p ~/.claude
rsync -av $OLD:'.claude/{settings.json,CLAUDE.md,keybindings.json,local-dev-servers.md,statusline-command.sh,workspace.md,telemetry.env}' ~/.claude/
rsync -av $OLD:'.claude/{hooks,agents,commands,output-styles,skills}' ~/.claude/
chmod +x ~/.claude/statusline-command.sh ~/.claude/hooks/* 2>/dev/null
```

Skip `.claude/mcp.json` — Claude Code reads global MCP servers from
`~/.claude.json`, not from there. Optional, saves re-adding MCP servers by
hand; ~400 KB with session cruft mixed in:

```bash
rsync -av $OLD:.claude.json ~/
```

After copying, **check every path referenced in `settings.json` exists**
(`fileSuggestion`, hooks, statusline). A stale path fails silently.

Also check what those scripts shell out to. `file-suggestion.sh` needs `rg`
and **`fzy`**, and fzy is not in the Brewfile — without it the hook returns
nothing and looks identical to a missing script. Hooks also run with a
stripped PATH, so anything mise-managed (python3, node) is unreachable from
one; prepend `/opt/homebrew/bin` inside the script.

### 2d. Claude memory

Feedback rules, in no git repo. There is a `memory/` dir per project, not one
central one, so pull them all:

```bash
rsync -av --include='*/' --include='memory/***' --exclude='*' \
  $OLD:.claude/projects/ ~/.claude/projects/
```

### 2e. Workspace state

Needs `~/dev/productive/work` from Step 4a, or just the dir. `workspaces/` and
`knowledge/me.md` are gitignored, so local-only.

**Notes only, no worktrees.** Worktrees are gigabytes and reproducible; pull
one only for a workspace you are actively mid-task on.

```bash
mkdir -p ~/dev/productive/work/workspaces
rsync -av \
  --exclude='/*/api/' --exclude='/*/frontend/' --exclude='/*/ai-agent/' \
  --exclude='/*/backoffice/' --exclude='/*/devportal/' --exclude='/*/logs/' \
  --exclude='.tmuxinator.yml' \
  $OLD:dev/productive/work/workspaces/ ~/dev/productive/work/workspaces/

rsync -av $OLD:dev/productive/work/knowledge/me.md ~/dev/productive/work/knowledge/
```

`.tmuxinator.yml` is excluded — herdr replaced tmuxinator.

Two things this keeps that matter: each workspace's `.claude/skills/*` entries
are **symlinks into its `api` worktree**, and the local-only notes git repo in
each workspace root.

> **Use rsync, not a zip.** A zip of a workspace dereferences those symlinks
> into real dirs, and `unzip` then fails with `Permission denied` on every one
> (it cannot write through a symlink-to-directory). `rsync -a` preserves them.
> If a symlink dangles afterwards, its target worktree just is not checked out
> yet, which is expected.

### 2f. Caddy routing table

One `reverse_proxy` block per worktree hostname. Pulled to a temp path because
a fresh `brew install caddy` writes its own default Caddyfile; merge by hand.

```bash
rsync -av $OLD:/opt/homebrew/etc/Caddyfile /tmp/Caddyfile.old
```

The current setup uses **`import` lines** pointing at per-workspace Caddyfiles
rather than one monolithic file. Ignore `work/scripts/setup-caddy.sh`; take the
imports. See `~/.claude/local-dev-servers.md`.

### 2g. Configs chezmoi does NOT manage

chezmoi covers `alacritty`, `ghostty` and `nvim` under `~/.config`, plus the
`home/` dotfiles. Everything below is outside it.

```bash
rsync -av $OLD:'.config/{herdr,workspaces,w,gh,git,atuin}' ~/.config/
rsync -av $OLD:.local/share/atuin ~/.local/share/
```

Custom keyboard layout, which exists nowhere but the old disk. **Install it to
`/Library/Keyboard Layouts`, not `~/Library`.** A user-level layout can be
selected but will not commit as a second *enabled* input source, which leaves
ABC as the only enabled layout and macOS then refuses to remove it — the minus
button stays greyed out. System-wide is also what the login window needs.

Note the literal space in the remote path: rsync 3.5 protects args by default,
so quoting or escaping it fails; pass it plain inside one quoted argument.

```bash
rsync -av "$OLD:/Library/Keyboard Layouts/Croatian-US.keylayout" \
          "$OLD:/Library/Keyboard Layouts/Croatian-US.icns" \
          /tmp/
sudo mv /tmp/Croatian-US.keylayout /tmp/Croatian-US.icns /Library/Keyboard\ Layouts/
```

Then add it by hand: **System Settings → Keyboard → Text Input → Input
Sources → Edit → + → Others → Croatian US**, then remove ABC. If it is not
listed, log out and back in; macOS only scans that dir at login.

`~/.local/share/atuin` is ~6 MB: years of shell history plus the `key` file
sync is keyed on. `zsh/tools.zsh` binds atuin to Ctrl+R.

`~/.config/herdr/agent-detection/` holds local rules that shadow upstream;
they are why herdr reports agent state correctly.

`~/.openpeon` (4.6 MB, 7 sound packs) is referenced by absolute path from
`ui.sound.done_path` / `ui.sound.request_path` in `config.toml`, so skipping it
makes `herdr config check` report missing sound files and silently fall back to
the built-in sounds. It is not peon-ping, which stays dead:

```bash
rsync -av $OLD:.openpeon/ ~/.openpeon/
herdr config check          # expect "config: ok"
herdr server reload-config
```

**Do not copy `~/.tool-versions`.** It was skipped last time on purpose; mise
reads each repo's own pins and `~/.config/mise/config.toml`. Copying it drags
in runtimes no repo asks for (erlang, elixir, bun, gleam, go).

### 2h. Personal CLIs

`~/.local/bin` holds `workspaces`, `w-popup`, `ov-popup`, `pr-popup`, `agent`
and the `tb-*` family. `--no-links` skips symlinks into `~/.local/share`
(those tools get reinstalled in Step 5).

```bash
mkdir -p ~/.local/bin
rsync -av --no-links $OLD:.local/bin/ ~/.local/bin/
chmod +x ~/.local/bin/*
rm -f ~/.local/bin/saggar ~/.local/bin/tb-lf     # trials, not in use
```

### 2i. TablePlus

The Brewfile installs the apps; it carries none of their settings. TablePlus is
the only one holding state worth moving. **Quit it on the old machine first.**

```bash
TP="Library/Application Support/com.tinyapp.TablePlus"
mkdir -p ~/"$TP"
rsync -av $OLD:"$TP/Data" $OLD:"$TP/.licensemac" ~/"$TP/"
rsync -av $OLD:Library/Preferences/com.tinyapp.TablePlus.plist ~/Library/Preferences/
```

Connection *passwords* live in the login Keychain, not these files. Re-enter on
first connect.

### 2j. Zen Browser profile — do this early

The `zen` cask comes from the Brewfile. The profile does not; it is ~4 GB
across profiles, and the active one is named in `profiles.ini` (last time
`ei91s0r8.Default (alpha)`). **Quit Zen on the old machine first.**

Sign into Firefox Sync on the new machine for bookmarks, history, passwords,
open tabs and extensions. Sync does **not** carry Zen's own settings:

```bash
Z="Library/Application Support/zen/Profiles/<profile>"
mkdir -p ~/"$Z"
rsync -av $OLD:"$Z/prefs.js" $OLD:"$Z/containers.json" \
          $OLD:"$Z/zen-themes.css" $OLD:"$Z/zen-keyboard-shortcuts.json" \
          $OLD:"$Z/zen-themes" $OLD:"$Z/zen-sessions-backup" ~/"$Z/"
rsync -av $OLD:Library/Application\ Support/zen/profiles.ini ~/Library/Application\ Support/zen/
```

This skips `storage/`, which is most of the size. `zen-sessions-backup`
(~52 MB) holds workspaces and split views; drop it to start clean.

Two things Sync does not carry, and neither does the list above:

- **MultiAccountContainers saved sites.** Its extension storage lives under
  `storage/default/moz-extension+++<uuid>`; pull that one dir if the container
  assignments matter, or reassign by hand.
- Saved passwords without Sync: `logins.json` is useless without `key4.db`
  from the same profile. Copy both or neither.

Whatever you do, **nuke whatever browsing you did on the new machine before
copying**, or the old profile merges into a half-used one.

### 2k. Apps with nothing worth carrying

Install and move on. Gitify is Electron cache behind one OAuth token, so log in
again. 1Password, Slack and Chrome restore from their accounts. Ghostty config
comes from the dotfiles repo.

Dropped for good: Hammerspoon, Keyboard Cowboy (both hotkey managers, both
retired — Raycast covers it), VS Code, and Alfred (Raycast replaces it — sign
into a Raycast account and settings, extensions, snippets and quicklinks sync
down; nothing to rsync). Alfred workflows are not importable into Raycast; the
old machine keeps `Library/Application Support/Alfred/` including the paid
Powerpack license, so do not delete it there.

---

## Step 3 — dotfiles

```bash
brew install chezmoi
git clone git@github.com:d4be4st/dotfiles ~/.dotfiles
~/.dotfiles/install
brew bundle install --file=~/.dotfiles/home/Brewfile
```

**Runtimes are on mise, not asdf.** `zprofile` activates mise. Install from the
repos' own pins rather than a personal `.tool-versions`:

```bash
mise install     # in each repo, or once ~/.config/mise/config.toml is in place
mise doctor
```

Do not copy `~/.asdf`; it is dead and its shims are already broken.

`~/.zprofile` sources `load-secrets.sh` and `load-otel.sh` from the `work`
repo, so Step 4a must run before a new shell is clean.

`home/gitignore` carries the global ignores (`mise.local.toml`, `.review.json`).

---

## Step 4 — Tier 3: reproducible, do not copy

### 4a. Repos

```bash
mkdir -p ~/dev/productive
git clone git@github.com:productiveio/work.git ~/dev/productive/work
cd ~/dev/productive/work && ./scripts/repo-sync.sh
```

Then `/setup` in the `work` repo for the rest: dirs, `~/.aws/config`,
telemetry, caddy, overcommit.

Two things that run needs to know: **skip `worktrees/`** (workspaces replaced
it), and every repo lives in `~/dev/productive/` with `work/repos/*` as
symlinks into them. Clone fresh, default branch only, no old branches.

### 4b. Claude plugins

~540 MB on the old machine. Reinstall from the marketplace instead:

```
/plugin install p-dev@productive
```

Then the rest from `knowledge/tooling/claude-plugins.md`.

### 4c. Session transcripts — optional, ~400 MB

Only needed for `tb-session` search over old work. Worth it, but **protect
today's local memory files**: the main pass excludes `memory/`, then a second
pass fills gaps without overwriting.

```bash
rsync -av --exclude='memory/' $OLD:.claude/projects/ ~/.claude/projects/
rsync -av --ignore-existing --include='*/' --include='memory/***' --exclude='*' \
  $OLD:.claude/projects/ ~/.claude/projects/
```

### 4d. Local Docker infrastructure

Nothing is carried; ~49 GB of images, volumes and build cache all rebuilds.
Meilisearch reindexes, `*-gems-data` and `*-node_modules-data` are just caches.

Clone under the repo's **own name** — the README's expected layout is
`local-development` alongside the sibling repos, and build contexts are
relative (`context: ../api`):

```bash
git clone git@github.com:productiveio/local-development.git ~/dev/productive/local-development
cd ~/dev/productive/local-development
docker compose up -d mysql redis memcached postgres meilisearch
```

OrbStack comes from the Brewfile. Manage this afterwards with the `tb-devctl`
skill rather than raw compose.

Four things that bit last time:

1. **There is no `mysql-test` service.** Older drafts of this runbook listed
   it; the compose file has no such service and the command fails. Five
   services, as above.
2. **`postgres:latest` is now 18.x and crash-loops** against the compose
   file's `postgres-data:/var/lib/postgresql/data` mount — PG 18 moved to
   major-version-specific data dirs and wants the mount at
   `/var/lib/postgresql`. Fix the mount (or pin the image). This is a repo bug
   that hits any fresh machine; the local fix is still uncommitted.
3. **polaris CI tests against postgres 16** (`sem-service start postgres 16`).
   Running 18 locally works but is a major version ahead of what is verified;
   first suspect if polaris misbehaves against the DB.
4. **`traefik` is in that compose file and binds :80/:443** — the same ports as
   Caddy. A bare `docker compose up -d` starts it as a dependency and it fights
   Caddy. Name the five services explicitly, and stop traefik if it appears.

**Ignore the README's `/etc/hosts` advice.** `*.productive.io.localhost`
resolves to loopback natively on macOS (RFC 6761) and Caddy fronts these
hostnames. See `~/.claude/local-dev-servers.md`.

Databases start empty. Re-seed however the team does it now; `db_backup`
(268 MB of dumps) is deliberately left behind.

---

## Step 5 — must re-login, cannot be copied [HUMAN]

- [ ] `gh auth login`
- [ ] `claude` login
- [ ] **`aws configure sso` before `aws sso login`.** A copied `~/.aws/config`
      without `sso_start_url` / `sso_region` fails with
      `Missing the following required SSO configuration values`.
- [ ] `brew install --cask session-manager-plugin` (for the `aws-mirror` skill)
- [ ] Productive VPN profile (NE VPN, reinstall the profile; `vpnutil` drives
      it after)
- [ ] `sudo caddy trust` — installs the local CA so `*.productive.io.localhost`
      HTTPS is clean. Needs an interactive sudo; Claude cannot run it.
- [ ] Keychain: `node ~/dev/productive/work/scripts/setup-keychain.mjs`.
      Two real entries: `PRODUCTIVE_CLAUDE_ALLOY_USERNAME` and
      `PRODUCTIVE_CLAUDE_ALLOY_PASSWORD`.
      **Unlock the keychain first** — a locked keychain makes
      `list-secrets.mjs` report 0 found and looks like an empty keychain.
- [ ] **Vanta** — install the agent (company requirement), lands a root daemon
      in `/Library/LaunchDaemons`.
- [ ] **Raycast** — free ⌘Space from Spotlight first, or Raycast's onboarding
      refuses the hotkey as already in use. Extensions install only from the
      Store GUI; start with GitHub, Git Repos, Kill Process, Brew.
- [ ] Reinstall vendored CLIs whose symlinks were skipped, only what you still
      want: `uv`. (`aider`, `posting`, `specify`, `cursor-agent` were trials.)
- [ ] 1Password, Chrome profile, Ghostty/Alacritty as apps.
- [ ] **1Password → Settings → Developer → Use the SSH agent.** `gitconfig`
      sets `commit.gpgsign=true` with `op-ssh-sign`, so until that toggle is on
      **every commit fails** with `1Password: Could not connect to socket`.
      Installing and unlocking the app is not enough; the toggle is separate.
      Confirm the socket exists:
      `ls ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock`
      (`s.sock` alone is 1Password's own IPC, not the SSH agent.)
      Separately, `gpg.ssh.allowedSignersFile` is unset, so `git log --show-signature`
      cannot verify these signatures even though they are valid.

### Optional: Zen under Marionette, for the browser MCP

The `firefox-devtools` MCP drives your real logged-in Zen profile, but Zen has
to be launched with the remote ports open. A LaunchAgent at
`~/Library/LaunchAgents/io.zen.marionette.plist` does it, `RunAtLoad`, no
`KeepAlive` (so quitting Zen stays quit), launching Zen with
`--marionette --remote-debugging-port 9222`. Ports 2828 and 9222.

```bash
launchctl kickstart -k gui/$(id -u)/io.zen.marionette     # restart without logout
```

The MCP itself goes in `~/.claude.json` at user scope. Skip the puppeteer
route and `claudecodebrowser`; both were dead ends.

---

## Step 6 — verify

Numbers below are what the finished machine reported on 2026-09-03. Treat a
mismatch as a question, not a failure — most deviations are old decisions.

```bash
ssh -T git@github.com                                    # greets you by username
mise ls                                                  # 7: 4x node, ruby, python, rust
node ~/dev/productive/work/scripts/list-secrets.mjs      # 5 found, 17 missing (all optional)
brew services list | grep -w caddy                       # started
curl -k -I https://api.productive.io.localhost/          # 502 is correct: routing works, Rails is down
workspaces list                                          # ~17 active + done + parked + inbox
ls ~/.claude/skills | wc -l                              # 24
ls ~/.claude/projects/-Users-stef-dev-productive-work/memory | wc -l   # 32
docker ps --format '{{.Names}}'                          # mysql redis memcached postgres meilisearch
launchctl list | grep -ci vanta                          # non-zero
aws sts get-caller-identity                              # AWSReservedSSO_DeveloperAccess
```

Then take a **baseline snapshot** while the machine is known-clean, so you have
something to diff against later: `launchctl list`, the LaunchDaemons and
LaunchAgents listings, `brew list`.

---

## Step 7 — close out the old machine [HUMAN]

Do not skip this. It stayed open for a full day last time.

```bash
# on the old machine
sudo systemsetup -setremotelogin off
```

Then remove the new machine's key from `~/.ssh/authorized_keys` there.

---

## Appendix A — unfinished work, pulled on demand

Worktrees with uncommitted working-tree changes are deliberately **not**
committed. Inventory them before you leave the old machine:

```bash
for d in ~/dev/productive/work/workspaces/*/*/; do
  git -C "$d" rev-parse --git-dir >/dev/null 2>&1 || continue
  n=$(git -C "$d" status --porcelain | wc -l)
  [ "$n" -gt 0 ] && echo "$n  $d"
done
```

When you actually resume one, recreate its worktree normally, then overlay the
working tree from the old machine:

```bash
SLUG=spec-first-test-refactor
REPO=api
rsync -av --exclude='.git' --exclude='node_modules' --exclude='tmp' --exclude='log' \
  $OLD:dev/productive/work/workspaces/$SLUG/$REPO/ \
  ~/dev/productive/work/workspaces/$SLUG/$REPO/
```

Check `git status` in the worktree afterwards and confirm the diff matches what
the old machine showed.

---

## Appendix B — deliberately left behind

**Rebuilt by a later step, not copied:** Docker images, volumes and build cache
(~49 GB, Step 4d); every git clone under `~/dev/productive/` (Steps 4a and 4d);
`~/.claude/plugins` (~540 MB, Step 4b); `node_modules` anywhere.

**Dead tooling:** `~/.asdf` (mise replaced it), `~/.env` (stale
`OPENROUTER_API_KEY` from the aider era), `~/.tool-versions`, `~/.aider*`,
`~/.kiro`, `~/.copilot`, `~/.gemini`, `~/.opencode`, `~/.antigravity`,
`~/.cursor`, `~/.agent-os`, `~/.claudecodebrowser`, `~/.ollama`,
`~/.hammerspoon`, everything peon-ping, and `~/.local/bin/{saggar,tb-lf}`.

**GUI app caches:** all of `Alfred/` (Raycast replaced it; the paid license
stays on the old machine), Gitify's Electron cache, TablePlus `Cache/` and
`Temp/`, VS Code extensions, and the Zen profile's `storage/` (minus the
MultiAccountContainers dir if you want it), `favicons.sqlite`,
`gmp-widevinecdm`, sync WAL files and any stale profile.

**Churn and history:** `~/.claude.json.tmp.*`,
`~/.claude/{cache,debug,downloads,paste-cache,shell-snapshots,sessions,session-data}`,
`~/dev/worktrees` and `~/dev/productive/worktrees`,
`~/dev/productive/db_backup` (268 MB of seed dumps).
