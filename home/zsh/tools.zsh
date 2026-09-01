# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# Atuin (fuzzy history — replaces Ctrl+R)
eval "$(atuin init zsh --disable-up-arrow)"

# Ghostty shell integration (OSC 133 prompt marks, passes through tmux)
# Hardcoded path — $GHOSTTY_RESOURCES_DIR isn't set inside tmux panes
_ghostty_int="/Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh/ghostty-integration"
[[ -f "$_ghostty_int" ]] && source "$_ghostty_int"
unset _ghostty_int

# Kiro IDE integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# gcloud shell completion (PATH handled in .zprofile)
if [ -f '/Users/stef/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/Users/stef/Downloads/google-cloud-sdk/completion.zsh.inc'
fi
