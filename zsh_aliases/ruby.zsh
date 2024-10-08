alias rbb='bundle'
alias rbbc='bundle clean'
alias rbbe='bundle exec'
alias rbbi='bundle install --path vendor/bundle'
alias rbbl='bundle list'
alias rbbo='bundle open'
alias rbbp='bundle package'
alias rbbu='bundle update'
alias rbbI='rbbi \
  && bundle package \
  && print .bundle       >>! .gitignore \
  && print vendor/assets >>! .gitignore \
  && print vendor/bundle >>! .gitignore \
  && print vendor/cache  >>! .gitignore'

alias rof='rspec --only-failures'

alias ram="git ls-files -m | xargs ls -1 2>/dev/null | grep -E '\.rake$|\.rb$' | xargs rubocop -A"
alias ras="git diff --name-only --cached | xargs ls -1 2>/dev/null | grep -E '\.rake$|\.rb$' | xargs rubocop -A"
alias els="git diff --name-only --cached | xargs ls -1 2>/dev/null | grep -E '\.ts$' | xargs eslint --fix"
