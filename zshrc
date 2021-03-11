export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zstyle ':prezto:*:*' color 'yes'
zstyle ':prezto:module:editor' key-bindings 'vi'
zstyle ':prezto:module:utility' safe-ops 'no'.
# # zstyle ':prezto:module:terminal' auto-title 'no'
zstyle ':prezto:module:syntax-highlighting' highlighters \
 'main' \
 'brackets' \
 'pattern' \
 'cursor' \
 'root'

zplug "modules/environment", from:prezto
zplug "djui/alias-tips"
zplug "modules/ruby", from:prezto

zplug "modules/git", from:prezto
zplug "modules/editor", from:prezto
zplug "modules/history", from:prezto
zplug "modules/terminal", from:prezto
zplug "modules/utility", from:prezto
zplug "desyncr/auto-ls"
# zplug "zuxfoucault/colored-man-pages_mod"
zplug "oz/safe-paste"
zplug "caarlos0/zsh-pg"
# zplug "jreese/zsh-titles"
zplug denysdovhan/spaceship-prompt, use:spaceship.zsh, from:github, as:theme
zplug "modules/completion", from:prezto, defer:1
zplug "Aloxaf/fzf-tab", defer:2
zplug "zdharma/fast-syntax-highlighting", defer:2
zplug "modules/history-substring-search", from:prezto, defer:3

zplug load
 
enable-fzf-tab

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-beginning-of-line

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
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
alias gm="git merge --no-edit"
alias gcpc="git cherry-pick --continue"
alias gcpa="git cherry-pick --abort"
alias gcps="git cherry-pick --skip"
alias OD="OVERCOMMIT_DISABLE=1"
pgld() {
 if [ -n "$1" ]
 then
   git log --after="$1 00:00:00" --before="$1 23:59:59" --author="Stjepan Hadjic" --reverse --pretty=format:'%s'
 else
   git log --since=0am --author="Stjepan Hadjic" --reverse --pretty=format:'* %s'
 fi
}

alias tl='tail -f log/development.log'
alias lg='lazygit'
alias rof='rspec --only-failures'

eval "$(fasd --init auto)"
. $(brew --prefix asdf)/asdf.sh

export PATH="./bin:$PATH"
export PATH="~/bin:$PATH"
