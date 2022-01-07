normal="#81B29A"
command="#719cd6"
warning="#dbc074"
fg_tab_active="#393b44"
fg_active="#dfdfe0"
fg_inactive="#526175"
bg_inactive="#192330"

set -g "status" "on"
set -g "status-justify" "left"

set -g "status-left-length" "100"
set -g "status-right-length" "100"
set -g "status-right-style" "none"

set -g "message-style" "fg=$fg_active,bg=$bg_inactive"

set -g "message-command-style" "fg=$fg_active,bg=$bg_inactive"

set -g "status-style" "none"
set -g "status-left-style" "none"

setw -g "window-status-style" "fg=$bg_inactive,bg=$bg_inactive,none"

setw -g "window-status-activity-style" "fg=$bg_inactive,bg=$bg_inactive,none"

setw -g "window-status-separator" ""

set -g "window-style" "fg=$fg_inactive,bg=$bg_inactive"
set -g "window-active-style" "fg=$fg_active,bg=$bg_inactive"

set -g "pane-border-style" "fg=$fg_active"
set -g "pane-active-border-style" "fg=$fg_active"

set -g "display-panes-active-colour" "$warning"
set -g "display-panes-colour" "$command"

set -g "status-bg" "$bg_inactive"
set -g "status-fg" "$fg_active"

set -g "@prefix_highlight_fg" "$bg_inactive"
set -g "@prefix_highlight_bg" "$normal"
set -g "@prefix_highlight_copy_mode_attr" "fg=$bg_inactive,bg=$normal"
set -g "@prefix_highlight_output_prefix" "  "

set -g status-left "#[fg=$fg_tab_active,bg=#{?client_prefix,$command,$normal},bold] #S "
set -g status-right ""
setw -g window-status-format " #[fg=$fg_active,bg=$bg_inactive] #I  #W "
setw -g window-status-current-format " #[fg=$fg_tab_active,bg=$fg_active,bold] #I  #W  #F "
