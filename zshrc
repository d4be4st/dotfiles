### Plugin manager

ZSHHOME=$HOME/.zsh
# where do you want to store your plugins?
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}

# get zsh_unplugged and store it with your other plugins
if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh

# Multiple Homebrews on Apple Silicon
if [ "$(arch)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . $(brew --prefix asdf)/libexec/asdf.sh
    export GITHUB_TOKEN=`gh auth token`
else
    eval "$(/usr/local/bin/brew shellenv)"
    alias d4="gameportingtoolkit-no-hud ~/WinGames 'C:\Program Files (x86)\Diablo IV\Diablo IV Launcher.exe'"
    export WINEPREFIX=~/my-game-prefix
fi

## Basic config

# fpath=($ZSHHOME/completions $(brew --prefix)/share/zsh/site-functions $fpath)
# autoload -Uz compinit
# compinit

### Plugins

plugins=(
  # use zsh-defer magic to load the remaining plugins at hypersonic speed!
  romkatv/zsh-defer

  # core plugins
  zsh-users/zsh-completions

  # user plugins
  rupa/z
  djui/alias-tips
  # sindresorhus/pure
)

# clone, source, and add to fpath
plugin-load $plugins

# autoload -U promptinit; promptinit
# prompt pure

### Aliases
alias es='exec $SHELL'
alias vi="nvim"
alias vim="nvim"
alias OD="OVERCOMMIT_DISABLE=1"
alias lg='lazygit'
alias cat='bat'

for file in $ZSHHOME/aliases/*.zsh; do
  source "$file"
done

path=(./bin ~/bin node_modules/.bin ~/.rd/bin ~/.local/bin $path)
path=(/opt/homebrew/opt/gnu-sed/libexec/gnubin $path)

. "$HOME/.local/bin/env"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/stef/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/stef/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/stef/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/stef/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Added by Antigravity
export PATH="/Users/stef/.antigravity/antigravity/bin:$PATH"

# Light prompt for nvim terminal panes.
# $NVIM is set by neovim for every terminal it opens.
# %2~ shows at most 2 path components (e.g. api/app/models → app/models).
if [[ -n "$NVIM" ]]; then
  PROMPT='%F{cyan}%2~%f ❯ '
fi
