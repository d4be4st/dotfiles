### Plugin manager

ZSHHOME=$HOME/.zsh
# where do you want to store your plugins?
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}

# get zsh_unplugged and store it with your other plugins
if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh

## Basic config

#fpath=($ZSHHOME/completions $(brew --prefix)/share/zsh/site-functions $fpath)
#autoload -Uz compinit
#compinit

### Plugins

plugins=(
  # use zsh-defer magic to load the remaining plugins at hypersonic speed!
  romkatv/zsh-defer

  # core plugins
  zsh-users/zsh-completions

  # user plugins
  rupa/z
  djui/alias-tips
)

# clone, source, and add to fpath
plugin-load $plugins

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

path=(./bin ~/bin node_modules/.bin ~/.rd/bin $path)

