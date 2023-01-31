### Plugin manager

ZSHHOME=$HOME/.zsh
source $ZSHHOME/plugins/zsh_unplugged/zsh_unplugged.plugin.zsh

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

. $(brew --prefix asdf)/asdf.sh

path=(./bin ~/bin node_modules/.bin ~/.rd/bin $path)
