# Catppuccin Mocha — matches Ghostty theme
thm_bg="#1e1e2e"
thm_fg="#cdd6f4"
thm_cyan="#89dceb"
thm_black="#181825"
thm_gray="#313244"
thm_magenta="#cba6f7"
thm_pink="#f5c2e7"
thm_red="#f38ba8"
thm_green="#a6e3a1"
thm_yellow="#f9e2af"
thm_blue="#89b4fa"
thm_orange="#fab387"
thm_black4="#585b70"

set -g status-style "bg=${thm_black},fg=${thm_fg}"
set -g status-left-length 40
set -g status-right-length 60

# Left: session name
set -g status-left "#[bg=${thm_blue},fg=${thm_black},bold] #S #[bg=${thm_black},fg=${thm_blue}]"

# Right: date + time
set -g status-right "#[fg=${thm_black4}] %Y-%m-%d  %H:%M "

# Window tabs
set -g window-status-format         "#[bg=${thm_black},fg=${thm_black4}] #I:#W "
set -g window-status-current-format "#[bg=${thm_gray},fg=${thm_blue},bold] #I:#W "
set -g window-status-separator      ""

# Pane borders
set -g pane-border-style        "fg=${thm_gray}"
set -g pane-active-border-style "fg=${thm_blue}"

# Message / command line
set -g message-style "bg=${thm_gray},fg=${thm_fg}"

# Copy mode
set -g mode-style "bg=${thm_blue},fg=${thm_black}"
