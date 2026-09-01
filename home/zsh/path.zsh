path=(
  ./bin
  ~/bin
  node_modules/.bin
  ~/.rd/bin
  ~/.local/bin
  ~/dev/productive/work/scripts
  /opt/homebrew/opt/gnu-sed/libexec/gnubin
  ~/.antigravity/antigravity/bin
  $path
)

# uv / pipx managed tools
if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi
