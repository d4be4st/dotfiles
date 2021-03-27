onedark_black="#282c34"
onedark_blue="#61afef"
onedark_yellow="#e5c07b"
onedark_red="#e06c75"
onedark_white="#aab2bf"
onedark_green="#98c379"
onedark_visual_grey="#3e4452"
onedark_comment_grey="#5c6370"

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

set -g status-left "#[fg=$onedark_visual_grey,bg=#{?client_prefix,$onedark_blue,$onedark_green},bold] #S #[fg=#{?client_prefix,$onedark_blue,$onedark_green},bg=$onedark_black,nobold,nounderscore,noitalics] "
set -g status-right ""
setw -g window-status-format "#[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics] #[fg=$onedark_white,bg=$onedark_black] #I  #W #[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics] "
setw -g window-status-current-format "#[fg=$onedark_black,bg=$onedark_white,nobold,nounderscore,noitalics] #[fg=$onedark_visual_grey,bg=$onedark_white,bold] #I  #W  #F #[fg=$onedark_white,bg=$onedark_black,nobold,nounderscore,noitalics] "

# set -g "status-right" "#[fg=$onedark_white,bg=$onedark_black,nounderscore,noitalics]${time_format}  ${date_format} #[fg=$onedark_visual_grey,bg=$onedark_black]#[fg=$onedark_visual_grey,bg=$onedark_visual_grey]#[fg=$onedark_white, bg=$onedark_visual_grey]${status_widgets} #[fg=$onedark_green,bg=$onedark_visual_grey,nobold,nounderscore,noitalics]#[fg=$onedark_black,bg=$onedark_green,bold] #h #[fg=$onedark_yellow, bg=$onedark_green]#[fg=$onedark_red,bg=$onedark_yellow]"
# set -g "status-left" "#[fg=$onedark_visual_grey,bg=$onedark_green,bold] #S #{prefix_highlight}#[fg=$onedark_green,bg=$onedark_black,nobold,nounderscore,noitalics]"

# set -g "window-status-format" "#[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics]#[fg=$onedark_white,bg=$onedark_black] #I  #W #[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics]"
# set -g "window-status-current-format" "#[fg=$onedark_black,bg=$onedark_visual_grey,nobold,nounderscore,noitalics]#[fg=$onedark_white,bg=$onedark_visual_grey,nobold] #I  #W #[fg=$onedark_visual_grey,bg=$onedark_black,nobold,nounderscore,noitalics]"
