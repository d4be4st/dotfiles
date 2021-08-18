onedark_black="#192330"
onedark_blue="#719cd6"
onedark_yellow="#dbc074"
onedark_red="#c94f6d"
onedark_white="#dfdfe0"
onedark_green="#81B29A"
onedark_visual_grey="#393b44"
onedark_comment_grey="#526175"

set -g "status" "on"
set -g "status-justify" "left"

set -g "status-left-length" "100"
set -g "status-right-length" "100"
set -g "status-right-style" "none"

set -g "message-style" "fg=$onedark_white,bg=$onedark_black"

set -g "message-command-style" "fg=$onedark_white,bg=$onedark_black"

set -g "status-style" "none"
set -g "status-left-style" "none"

setw -g "window-status-style" "fg=$onedark_black,bg=$onedark_black,none"

setw -g "window-status-activity-style" "fg=$onedark_black,bg=$onedark_black,none"

setw -g "window-status-separator" ""

set -g "window-style" "fg=$onedark_comment_grey,bg=$onedark_black"
set -g "window-active-style" "fg=$onedark_white,bg=$onedark_black"

set -g "pane-border-style" "fg=$onedark_white"
set -g "pane-active-border-style" "fg=$onedark_white"

set -g "display-panes-active-colour" "$onedark_yellow"
set -g "display-panes-colour" "$onedark_blue"

set -g "status-bg" "$onedark_black"
set -g "status-fg" "$onedark_white"

set -g "@prefix_highlight_fg" "$onedark_black"
set -g "@prefix_highlight_bg" "$onedark_green"
set -g "@prefix_highlight_copy_mode_attr" "fg=$onedark_black,bg=$onedark_green"
set -g "@prefix_highlight_output_prefix" "  "

set -g status-left "#[fg=$onedark_visual_grey,bg=#{?client_prefix,$onedark_blue,$onedark_green},bold] #S "
set -g status-right ""
setw -g window-status-format " #[fg=$onedark_white,bg=$onedark_black] #I  #W "
setw -g window-status-current-format " #[fg=$onedark_visual_grey,bg=$onedark_white,bold] #I  #W  #F "
