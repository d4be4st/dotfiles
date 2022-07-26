export ZPLUG_HOME=/usr/local/opt/zplug
export ZSH_CACHE_DIR=/usr/local/opt/zplug/cache
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
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'H' vi-beginning-of-line

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias es='exec $SHELL'
alias ssh="TERM=xterm-256color ssh"
alias aterm='TERM=xterm-256color'
alias msd='mina staging deploy'
alias mpd='mina production deploy'
alias mps='mina production ssh'
alias mss='mina staging ssh'
alias md='mina deploy'
alias ms='mina ssh'
alias vi="nvim"
alias vim="nvim"
alias minad="/Users/stef/dev/gems/mina/bin/mina"
alias gm="git merge --no-edit --no-ff"
alias gcpc="git cherry-pick --continue"
alias gcpa="git cherry-pick --abort"
alias gcps="git cherry-pick --skip"
alias OD="OVERCOMMIT_DISABLE=1"
alias tl='tail -f log/development.log'
alias lg='lazygit'
alias rof='rspec --only-failures'

eval "$(fasd --init auto)"
. $(brew --prefix asdf)/asdf.sh

export PATH="./bin:$PATH"
export PATH="~/bin:$PATH"

function awsexec () {
  local service_name=$1
  local task_number=$(aws ecs list-tasks --cluster coinmara-dev-cluster --service-name $service_name | jq '.["taskArns"][0]' | sed 's/.*\/.*\/\(.*\)"/\1/')
  if [[ -z "$task_number" ]]
  then print "No tasks found"
  else
    print "Connecting to task $task_number ..."
    aws ecs execute-command --cluster coinmara-dev-cluster --container $service_name --interactive --command "/bin/bash -i" --task $task_number
  fi
}

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform
