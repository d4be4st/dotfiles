# This tmux statusbar config was created by tmuxline.vim
# on Sun, 02 Aug 2020

onedark_black="#282c34"
onedark_blue="#61afef"
onedark_yellow="#e5c07b"
onedark_red="#e06c75"
onedark_white="#aab2bf"
onedark_green="#98c379"
onedark_visual_grey="#3e4452"
onedark_comment_grey="#5c6370"

set -g status-justify "left"
set -g status "on"
set -g status-left-style "none"
set -g message-command-style "fg=colour231,bg=colour31"
set -g status-right-style "none"
set -g pane-active-border-style "fg=colour254"
set -g status-style "none,fg=$onedark_white,bg=$onedark_black"
set -g message-style "fg=colour231,bg=colour31"
set -g pane-border-style "fg=colour240"
set -g status-right-length "100"
set -g status-left-length "100"
setw -g window-status-activity-style "underscore,fg=colour250,bg=colour234"
setw -g window-status-separator ""
setw -g window-status-style "none,fg=colour250,bg=colour234"
set -g status-left "#[fg=colour7,bg=colour0,bold] #S #[fg=colour8,bg=colour0,nobold,nounderscore,noitalics]"
set -g status-right ""
setw -g window-status-format ""
setw -g window-status-current-format ""
# setw -g window-status-format "#[fg=colour8,bg=colour0,nobold,nounderscore,noitalics]#I  #W #[fg=colour8,bg=colour0,nobold,nounderscore,noitalics]"
# setw -g window-status-current-format "#[fg=colour0,bg=colour8,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour8,bold] #I  #W  #F #[fg=colour8,bg=colour0,nobold,nounderscore,noitalics]"

# 234 = 0
# 31 = 8
# 231 = 7
# set "status-right" "#[fg=$onedark_white,bg=$onedark_black,nounderscore,noitalics]${time_format}  ${date_format} #[fg=$onedark_visual_grey,bg=$onedark_black]#[fg=$onedark_visual_grey,bg=$onedark_visual_grey]#[fg=$onedark_white, bg=$onedark_visual_grey]${status_widgets} #[fg=$onedark_green,bg=$onedark_visual_grey,nobold,nounderscore,noitalics]#[fg=$onedark_black,bg=$onedark_green,bold] #h #[fg=$onedark_yellow, bg=$onedark_green]#[fg=$onedark_red,bg=$onedark_yellow]"
# set "status-left" "#[fg=$onedark_visual_grey,bg=$onedark_green,bold] #S #{prefix_highlight}#[fg=$onedark_green,bg=$onedark_black,nobold,nounderscore,noitalics]"

# set "window-status-format" "#[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics]#[fg=$onedark_white,bg=$onedark_black] #I  #W #[fg=$onedark_black,bg=$onedark_black,nobold,nounderscore,noitalics]"
# set "window-status-current-format" "#[fg=$onedark_black,bg=$onedark_visual_grey,nobold,nounderscore,noitalics]#[fg=$onedark_white,bg=$onedark_visual_grey,nobold] #I  #W #[fg=$onedark_visual_grey,bg=$onedark_black,nobold,nounderscore,noitalics]"
