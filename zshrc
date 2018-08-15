source ~/.zplug/init.zsh


zstyle ':prezto:*:*' color 'yes'
zstyle ':prezto:module:editor' key-bindings 'vi'

zstyle ':prezto:module:syntax-highlighting' highlighters \
  'main' \
  'brackets' \
  'pattern' \
  'cursor' \
  'root'

zplug "modules/environment", from:prezto
zplug "djui/alias-tips"
zplug "modules/ruby", from:prezto
zplug "plugins/rake-fast", from:oh-my-zsh

zplug "modules/git", from:prezto
zplug "modules/editor", from:prezto
zplug "modules/history", from:prezto
zplug "modules/terminal", from:prezto
zplug "modules/utility", from:prezto
zplug "desyncr/auto-ls"
zplug "walesmd/caniuse.plugin.zsh"
zplug "zuxfoucault/colored-man-pages_mod"
zplug "oz/safe-paste"
zplug "caarlos0/zsh-pg"
zplug "jreese/zsh-titles"
zplug denysdovhan/spaceship-prompt, use:spaceship.zsh, from:github, as:theme
zplug "modules/completion", from:prezto, defer:1
# zplug "modules/syntax-highlighting", from:prezto, defer:2
zplug "zdharma/fast-syntax-highlighting", defer:2
zplug "modules/history-substring-search", from:prezto, defer:3

zplug load

spaceship_vi_mode_disable
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"
source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash
# source $HOME/dotfiles/tmuxinator.zsh

alias es='exec $SHELL'
alias gu='git up'
alias msd='mina staging deploy'
alias mpd='mina production deploy'
alias md='mina deploy'
alias mps='mina production ssh'
alias mss='mina staging ssh'
alias ms='mina ssh'
alias vi="nvim"
alias vim="nvim"
alias minad="/Users/stef/dev/gems/mina/bin/mina"
pgld() {
  if [ -n "$1" ]
  then
    git log --after="$1 00:00:00" --before="$1 23:59:59" --author="Stjepan Hadjic" --reverse --pretty=format:'%s'
  else
    git log --since=0am --author="Stjepan Hadjic" --reverse --pretty=format:'* %s'
  fi
}

alias tl='tail -f log/development.log'

eval "$(fasd --init auto)"
export PATH="./bin:$PATH"
export PATH="node_modules/.bin:$PATH"
