scriptencoding utf-8

" map leader key to comma
let mapleader = "\<space>"


" define a group `vimrc` and initialize.
" http://rbtnn.hateblo.jp/entry/2014/12/28/010913
augroup vimrc
  autocmd!
augroup END

call plug#begin()

" Dependencies
" Plug 'Shougo/denite.nvim'
" Plug 'Shougo/unite.vim' " for vimfiler

" Windows
" Plug 'zefei/vim-wintabs'

"" Theme
Plug 'joshdick/onedark.vim'
" {{{
  let g:onedark_termcolors = 16
" }}}
Plug 'rakr/vim-one'

"" Alignment
Plug 'junegunn/vim-easy-align'
" {{{
  xmap <leader>a <Plug>(EasyAlign)
  nmap <leader>a <Plug>(EasyAlign)
" }}}

" Beautify
Plug 'Chiel92/vim-autoformat'

"" Brackets,quotes etc
Plug 'jiangmiao/auto-pairs'
" {{{
  let g:AutoPairsFlyMode = 0
" }}}

"" Filetree
" let g:loaded_python3_provider = 1
" Plug 'ipod825/vim-netranger'
" Plug 'Shougo/vimfiler.vim'
" " {{{
"   let g:vimfiler_as_default_explorer = 1
"   let g:vimfiler_safe_mode_by_default = 0
"   nnoremap <silent> <leader>vf :VimFilerExplorer -no-quit -toggle<CR>
"   nnoremap <silent> <leader>vg :VimFilerExplorer -no-quit -find<CR>
"   " nnoremap <buffer> <C-l> <Plug>(vimfiler_switch_to_other_window)
" }}}
Plug 'zgpio/tree.nvim'
" {{{
  nnoremap <silent> <leader>vf :<C-u>Tree -columns=mark:git:indent:icon:filename:size
      \ -split=vertical
      \ -direction=topleft
      \ -winwidth=40
      \ -listed
      \ `expand('%:p:h')`<CR>

  " call tree#custom#option('_', {
  "       \ 'root_marker': '',
  "       \ })
" }}}

" {{{
  " let g:netrw_banner            = 0
  " let g:netrw_browse_split      = 1 " Vertical split
  " let g:netrw_liststyle         = 3
  " nnoremap <silent> <leader>vf :Lex<CR>
" }}}

"" Fuzzy search
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
" {{{
  let g:fzf_nvim_statusline = 0 " disable statusline overwriting
  nnoremap <silent> <leader>ff :Files<CR>
  nnoremap <silent> <leader>fb :Buffers<CR>
  nnoremap <silent> <leader>fw :Windows<CR>
  nnoremap <silent> <leader>fl :BLines<CR>
  nnoremap <silent> <leader>ft :BTags<CR>
  nnoremap <silent> <leader>fh :History<CR>
  nnoremap <silent> <leader>fm :Maps<CR>
  nnoremap <silent> <leader>fs :Snippets<CR>
  nnoremap <silent> <leader>fy :Filetypes<CR>
  autocmd vimrc Filetype fzf nnoremap <buffer> <Esc><Esc> :q<cr>
" }}}

"" Html tags
Plug 'alvan/vim-closetag'
" {{{
  let g:closetag_filenames = '*.html,*.vue,*.md,*.rb'
" }}}

"" Lightline
Plug 'itchyny/lightline.vim'
" {{{
  function! LightLineModified()
    if &filetype ==? 'help'
      return ''
    elseif &modified
      return '+'
    elseif &modifiable
      return ''
    else
      return ''
    endif
  endfunction

  function! LightLineReadonly()
    if &filetype ==? 'help'
      return ''
    elseif &readonly
      return 'RO'
    else
      return ''
    endif
  endfunction

  function! LightLineFugitive()
    return exists('*fugitive#head') ? fugitive#head() : ''
  endfunction

  function! LightLineGitGutter()
    if ! exists('*GitGutterGetHunkSummary')
          \ || ! get(g:, 'gitgutter_enabled', 0)
          \ || winwidth('.') <= 90
      return ''
    endif
    let symbols = [
          \ g:gitgutter_sign_added,
          \ g:gitgutter_sign_modified,
          \ g:gitgutter_sign_removed
          \ ]
    let hunks = GitGutterGetHunkSummary()
    let ret = []
    for i in [0, 1, 2]
      if hunks[i] > 0
        call add(ret, symbols[i] . hunks[i])
      endif
    endfor
    return join(ret, ' ')
  endfunction

  function! LightLineFilename()
    return ('' !=? LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ ('' !=? expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' !=? LightLineModified() ? ' ' . LightLineModified() : '')
  endfunction

  function! LightLineNeomakeErrors()
    if !exists(':Neomake') || ((get(neomake#statusline#QflistCounts(), 'E', 0) + get(neomake#statusline#LoclistCounts(), 'E', 0)) == 0)
      return ''
    endif
    return 'E:'.(get(neomake#statusline#LoclistCounts(), 'E', 0) + get(neomake#statusline#QflistCounts(), 'E', 0))
  endfunction

  function! LightLineNeomakeWarnings()
    if !exists(':Neomake') || ((get(neomake#statusline#QflistCounts(), 'W', 0) + get(neomake#statusline#LoclistCounts(), 'W', 0)) == 0)
      return ''
    endif
    return 'W:'.(get(neomake#statusline#LoclistCounts(), 'W', 0) + get(neomake#statusline#QflistCounts(), 'W', 0))
  endfunction

  let g:lightline = {
        \ 'colorscheme': $ITERM_PROFILE == 'Light' ?  'one' : 'onedark',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'cocstatus', 'gitgutter', 'filename' ] ],
        \   'right': [ [ 'percent', 'lineinfo' ],
        \              [ 'neomake_errors', 'neomake_warnings' ],
        \              [ 'filetype' ] ]
        \ },
        \ 'component_function': {
        \   'fugitive': 'LightLineFugitive',
        \   'gitgutter': 'LightLineGitGutter',
        \   'readonly': 'LightLineReadonly',
        \   'modified': 'LightLineModified',
        \   'neomake_errors': 'LightLineNeomakeErrors',
        \   'neomake_warnings': 'LightLineNeomakeWarnings',
        \   'filename': 'LightLineFilename',
        \   'cocstatus': 'coc#status'
        \ },
        \ 'separator': { 'left': '▓▒░', 'right': '░▒▓' },
        \ 'subseparator': { 'left': '>', 'right': '' }
        \ }
  set noshowmode
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
" }}}

" Plug 'TaDaa/vimade'

" Wakatime
Plug 'wakatime/vim-wakatime'

" Plug 'neoclide/coc.nvim', {'branch': 'release'}
"""
  " set cmdheight=2
  " set updatetime=300
  " set shortmess+=c
  " set signcolumn=yes

  " " Remap keys for gotos
  " " nmap <silent> gd <Plug>(coc-definition)
  " " nmap <silent> gy <Plug>(coc-type-definition)
  " " nmap <silent> gi <Plug>(coc-implementation)
  " " nmap <silent> gr <Plug>(coc-references)

  " " Trigger completion
  " inoremap <silent><expr> <c-n> coc#refresh()
  " " Use <C-l> for trigger snippet expand.
  " imap <C-l> <Plug>(coc-snippets-expand)

  " " Use <C-j> for select text for visual placeholder of snippet.
  " vmap <C-j> <Plug>(coc-snippets-select)

  " " Commment higliht
  " autocmd FileType json syntax match Comment +\/\/.\+$+
"""
" Snippets
Plug 'Shougo/neosnippet.vim'
" {{{
  let g:neosnippet#disable_runtime_snippets = {
    \ '_': 1,
    \ }
  let g:neosnippet#snippets_directory='~/.config/nvim/snippets'
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)
" }}}
Plug 'prabirshrestha/asyncomplete-neosnippet.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-tags.vim'
" {{{
  let g:asyncomplete_auto_popup = 0
  let g:asyncomplete_remove_duplicates = 1
  " let g:asyncomplete_log_file = '/Users/stef/.config/nvim/async.log'
  imap <C-n> <Plug>(asyncomplete_force_refresh)
  au vimrc User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    \ 'name': 'file',
    \ 'whitelist': ['*'],
    \ 'priority': 10,
    \ 'completor': function('asyncomplete#sources#file#completor')
    \ }))
  au vimrc User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ }))
  au vimrc User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
    \ 'name': 'neosnippet',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#neosnippet#completor'),
    \ }))
  au vimrc User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
    \ 'name': 'tags',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#tags#completor'),
    \ }))
" }}}

" Commenting
Plug 'ddollar/nerdcommenter'
" {{{
  let g:NERDCustomDelimiters = { 'eruby.yaml': { 'left': '#' } }
" }}}

" Search across project
Plug 'dyng/ctrlsf.vim'
" {{{
  let g:ctrlsf_ackprg = 'rg'
  nmap <leader>gg <Plug>CtrlSFPrompt
  nmap <leader>gv <Plug>CtrlSFVwordExec
  nmap <leader>gw <Plug>CtrlSFCCwordExec
  nmap <leader>gs <Plug>CtrlSFPwordPath
" }}}

" Flash yanked
Plug 'machakann/vim-highlightedyank'
" {{{
  let g:highlightedyank_highlight_duration = 100
" }}}

" Async runner / linter
Plug 'benekastah/neomake'
" {{{
  autocmd! vimrc BufWritePost * Neomake
  let g:neomake_ruby_enabled_makers = ['mri', 'rubocop', 'ctags', 'reek']
  let g:neomake_ruby_rubocop_maker = {
      \ 'args': ['-D', '--force-exclusion']
      \ }
  let g:neomake_ruby_ctags_maker = {
      \ 'args': ['--languages=Ruby', '-R'],
      \ 'append_file': 0
      \ }
  let g:neomake_javascript_eslint_exe = $PWD .'/node_modules/.bin/eslint'
  let g:neomake_javascript_enabled_makers = ['eslint']
  let g:neomake_vue_eslint_exe = $PWD .'/node_modules/.bin/eslint'
  let g:neomake_vue_enabled_makers = ['eslint']
  let g:neomake_vue_eslint_maker = {
        \ 'args': ['--plugin=vue', '--format=compact'],
        \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
        \   '%W%f: line %l\, col %c\, Warning - %m,%-G,%-G%*\d problems%#',
        \ 'cwd': '%:p:h',
        \ 'output_stream': 'stdout',
        \ }
  let g:neomake_elixir_enabled_makers = ['credo']
  " let g:neomake_elixir_format_maker = {
  "     \ 'exe': 'mix',
  "     \ 'args': ['format']
  "     \ }
" }}}
Plug 'mhinz/vim-mix-format'
" {{{
  let g:mix_format_on_save = 1
" }}}

Plug 'AndrewRadev/splitjoin.vim'
" {{{
  let g:splitjoin_ruby_hanging_args = 0
  let g:splitjoin_ruby_curly_braces = 0
" }}}

" Syntax highlihgt
Plug 'sheerun/vim-polyglot'
" {{{
  let g:vim_markdown_conceal = 0
  let g:vim_markdown_fenced_languages = ['ruby', 'html', 'bash=sh']
" }}}

" Plug 'tpope/vim-markdown'
" let g:markdown_fenced_languages = ['ruby', 'html', 'bash=sh']



" Tests - running inside vim
Plug 'janko-m/vim-test'
" {{{
  let test#strategy = 'neovim'
  " let test#neovim#term_position = "vertical"
  let test#ruby#rspec#options = {
  \ 'file':    '--format documentation',
  \ 'nearest':    '--format documentation'
  \}
  nmap <silent> <leader>sn :TestNearest<CR>
  nmap <silent> <leader>sf :TestFile<CR>
  nmap <silent> <leader>sl :TestLast<CR>
  nmap <silent> <leader>ss :TestSuite<CR>
" }}}

" Whitespace remover
Plug 'ntpeters/vim-better-whitespace'
" {{{
  " autocmd vimrc BufEnter * EnableStripWhitespaceOnSave
  let g:better_whitespace_enabled=1
  let g:strip_whitespace_on_save=1
  let g:strip_whitespace_confirm=0
" }}}

" file tree
Plug 'mcchrish/nnn.vim'
" {{{
  let g:nnn#set_default_mappings = 0
  let g:nnn#layout = { 'left': '~20%' } "
  let g:nnn#action = {
      \ '<c-t>': 'tab split',
      \ '<c-x>': 'split',
      \ '<c-v>': 'vsplit' }
  let g:nnn#command = 'nnn -l'
  nnoremap <silent> <leader>vv :NnnPicker<CR>
  nnoremap <silent> <leader>vf :NnnPicker '%:p:h'<CR>
" }}}
" Plug 'RRethy/vim-hexokinase'
" " {{{
"   let g:Hexokinase_refreshEvents = ['BufWritePost']
"   let g:Hexokinase_ftAutoload = ['css', 'scss', 'sass']
" " }}}

Plug 'airblade/vim-gitgutter'         " Show git diff in gutter
Plug 'tpope/vim-fugitive'             " Awesome git plugin
Plug 'tpope/vim-endwise'              " autocomplete end
Plug 'tpope/vim-repeat'               " Enables dot command repeating for vim-surround, vim-unimpaired, etc
Plug 'tpope/vim-eunuch'               " file commands
" Plug 'AGhost-7/critiq.vim'            " Github pull requests
" Plug 'ap/vim-css-color'               " adds color to hex colors in CSS
Plug 'mkitt/tabline.vim'              " tab improvements
Plug 'chrisbra/csv.vim'               " CSV tables
Plug 'tpope/vim-surround'             " Awesome surround plugin
Plug 'fcpg/vim-spotlightify'          " Advanced search via /
Plug 'Yggdroot/indentLine'            " Display the indention levels
Plug 'whiteinge/diffconflicts'        " Better git mergetool
Plug 'wellle/targets.vim'             " Better object targets
Plug 'ryvnf/readline.vim'             " Readline style mappings for command-line mode in Vim
Plug 'psliwka/vim-smoothie'

" Languages
" Ruby
Plug 'vim-ruby/vim-ruby'
" }}}
  let g:ruby_indent_block_style = 'do'
" {{{
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rbenv'
Plug 'tpope/vim-bundler'
Plug 'ck3g/vim-change-hash-syntax'

" Javascript
Plug 'pangloss/vim-javascript'



" Markdown with rust
" function! BuildComposer(info)
"   if a:info.status !=? 'unchanged' || a:info.force
"     !cargo build --release
"   endif
" endfunction
" Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }

call plug#end()

" Theme
" set t_8f=[38;2;%lu;%lu;%lum
" set t_8b=[48;2;%lu;%lu;%lum
"syntax enable
" set t_Co=256

set termguicolors
if $ITERM_PROFILE == 'Light'
  set background=light
  colorscheme one
else
  set background=dark
  colorscheme onedark
endif


" Settings
set noswapfile


set inccommand=split
set regexpengine=1
set gdefault

" Set tab to 2 spaces, disable wrapping, tweaks
set shiftwidth=2
set nowrap
set tabstop=2
set expandtab
set showtabline=2

" Show line numbers
set number

" Make backspace behave sane
set backspace=2

" Show trailing and preceeding whitespace, show tabs
set list
set listchars=""
set listchars=tab:\|\
set listchars+=trail:.
set listchars+=extends:>
set listchars+=precedes:<

" Search tweaks
set ignorecase
set smartcase

" Ask to save changes if there are unsaved changes instead of not exiting
set confirm

" Never hide the mouse
set nomousehide

set nohidden

" Position splits logically
set splitbelow
set splitright

" Color columns after 80
set colorcolumn=100
set ttimeoutlen=50
set nolazyredraw
set scrolloff=5

" Disable commenting with o and O
autocmd vimrc FileType * setlocal formatoptions-=o

" opens buffer in new tab
set switchbuf+=usetab,newtab

" Maintain undo history between sessions
set undofile
set undodir=~/.config/nvim/undodir

" Automatic file refresh
autocmd vimrc BufEnter,FocusGained * :checktime

" Remove highlights
nnoremap <silent> <Esc><Esc> :nohlsearch<CR><Esc>

" Config
map <silent> <leader>r :so ~/.config/nvim/init.vim<cr>

" Undo
nnoremap U <C-r>

" Allow misspellings
cnoreabbrev qw wq
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev Bd bd
cnoreabbrev bD bd
cnoreabbrev t tabe
cnoreabbrev qt tabclose
nnoremap q: :q<CR>

" Duplicate current file
nmap <leader>od :let @1 = expand("%")<CR> :sav <C-R>1
" Move/Rename current file
nmap <leader>om :let @1 = expand("%")<CR> :! mv % <C-R>1

" Saner command line history
cnoremap <c-n>  <down>
cnoremap <c-p>  <up>

" Don't lose selection when shifting sidewards
xnoremap <  <gv
xnoremap >  >gv

" Terminal
tnoremap <ESC> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
tnoremap <C-b> <C-\><C-n><C-b>
tnoremap <C-f> <C-\><C-n><C-f>
autocmd vimrc BufEnter * if &buftype == 'terminal' | :startinsert | endif

" Opening splits with terminal in all directions
nnoremap <Leader>th :leftabove  vnew<CR>:terminal<CR>
nnoremap <Leader>tl :rightbelow vnew<CR>:terminal<CR>
nnoremap <Leader>tk :leftabove  new<CR>:terminal<CR>
nnoremap <Leader>tj :rightbelow new<CR>:terminal<CR>
nnoremap <leader>tt :tabe<CR>:terminal<CR>

" Easier window switching
" nmap <silent> <C-w><C-w> :call utils#intelligentCycling()<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Same when moving up and down
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap <C-f> <C-f>zz
nnoremap <C-b> <C-b>zz
vnoremap <C-u> <C-u>zz
vnoremap <C-d> <C-d>zz
vnoremap <C-f> <C-f>zz
vnoremap <C-b> <C-b>zz

" Remap H and L (top, bottom of screen to left and right end of line)
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L g_

" More logical Y (default was alias for yy)
nnoremap Y y$

" Yank and paste from clipboard
" set clipboard=unnamed
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y
vnoremap <leader>Y "+Y
nnoremap <leader>yy "+yy
nnoremap <leader>p "+p
vnoremap <leader>p "+p

" Search selected text
vnoremap // y/<C-R>"<CR>

" Delete and change to black hole
nnoremap <leader>d "_dd
vnoremap <leader>d "_d

" Always paste the last yank
" nnoremap p "0p
" vnoremap p "0p
" xnoremap p "0p

" nnoremap d "_d
" nnoremap D "_D
" vnoremap d "_d
" nnoremap c "_c
" vnoremap c "_c
" nnoremap C "_C
" xnoremap p "_dP
" " Cut
" nnoremap <leader>D dd
" vnoremap <leader>D dd
" nnoremap <leader>d d
" vnoremap <leader>d d

" Keep the cursor in place while joining lines
nnoremap J mzJ`z

" [S]plit line (sister to [J]oin lines) S is covered by cc.
nnoremap S mzi<CR><ESC>`z

" New line
nmap <C-\> o<Esc>
imap <C-\> <Esc>o

" Select all text
noremap vA ggVG

" Switch between tabs
" set Ctrl-n to S-Fn in iterm prefs
if exists('$TMUX')
  nmap <S-F1> 1gt
  nmap <S-F2> 2gt
  nmap <S-F3> 3gt
  nmap <S-F4> 4gt
  nmap <S-F5> 5gt
  nmap <S-F6> 6gt
  nmap <S-F7> 7gt
  nmap <S-F8> 8gt
  nmap <S-F9> 9gt
else
  nmap <F13> 1gt
  nmap <F14> 2gt
  nmap <F15> 3gt
  nmap <F16> 4gt
  nmap <F17> 5gt
  nmap <F18> 6gt
  nmap <F19> 7gt
  nmap <F20> 8gt
  nmap <F21> 9gt
endif

" Intelligent windows resizing using ctrl + arrow keys
"nnoremap <silent> <A-right> :call utils#intelligentVerticalResize('right')<CR>
"nnoremap <silent> <A-left> :call utils#intelligentVerticalResize('left')<CR>
"nnoremap <silent> <A-up> :resize +1<CR>
nnoremap <S-Up>    :resize +2<CR>
nnoremap <S-Down>  :resize -2<CR>
nnoremap <S-Left>  :vertical resize +2<CR>
nnoremap <S-Right> :vertical resize -2<CR>
" Zoom one pane
nnoremap <leader>- <C-W><C-\|><C-W><C-_>
" Restore panes
nnoremap <leader>= <C-w><C-=>

" Creating splits withyempty buffers in all directions
nnoremap <Leader>nh :leftabove  vnew<CR>
nnoremap <Leader>nl :rightbelow vnew<CR>
nnoremap <Leader>nk :leftabove  new<CR>
nnoremap <Leader>nj :rightbelow new<CR>
nnoremap <Leader>nt :tabe<CR>

" Emacs in command line
cnoremap <c-a> <home>
cnoremap <c-e> <end>

" Color debug
map <Leader>b :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
