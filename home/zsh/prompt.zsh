# Native zsh prompt — no framework, no startup cost
# Format: 22:51 ~/dev/work [main +2 -1] ❯

if [[ -n "$NVIM" ]]; then
  # Minimal prompt inside nvim terminal panes
  PROMPT='%F{cyan}%2~%f ❯ '
  return
fi

autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:git:*' enable git
zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' check-for-changes false

_prompt_git=""

_prompt_precmd() {
  vcs_info
  if [[ -n "$vcs_info_msg_0_" ]]; then
    local st
    st=$(git status --porcelain 2>/dev/null)
    local staged=0 unstaged=0
    if [[ -n "$st" ]]; then
      staged=$(echo "$st" | grep -cE '^[MADRCU]' 2>/dev/null); staged=${staged:-0}
      unstaged=$(echo "$st" | grep -cE '^.[MADRCU?]' 2>/dev/null); unstaged=${unstaged:-0}
    fi
    local info="%F{yellow}${vcs_info_msg_0_}%f"
    (( staged > 0 ))   && info+=" %F{green}+${staged}%f"
    (( unstaged > 0 )) && info+=" %F{red}-${unstaged}%f"
    _prompt_git=" [${info}]"
  else
    _prompt_git=""
  fi
}

add-zsh-hook precmd _prompt_precmd
setopt PROMPT_SUBST
PROMPT='%F{240}%T%f %F{cyan}%2~%f${_prompt_git}
%(?.%F{blue}.%F{red})❯%f '
