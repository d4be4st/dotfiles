ZSHHOME=$HOME/.zsh
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}

if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh

plugins=(
  romkatv/zsh-defer
  zsh-users/zsh-completions
  djui/alias-tips
  zsh-users/zsh-autosuggestions
)

plugin-load $plugins
