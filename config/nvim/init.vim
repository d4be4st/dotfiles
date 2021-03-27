scriptencoding utf-8

" map leader key to comma
let mapleader = "\<space>"

" define a group `vimrc` and initialize.
" http://rbtnn.hateblo.jp/entry/2014/12/28/010913
augroup vimrc
  autocmd!
augroup END

call plug#begin()

" Theme
Plug 'joshdick/onedark.vim'
" {{{
  let g:onedark_termcolors = 16
" }}}

"" Brackets,quotes etc
Plug 'rstacruz/vim-closer'

" f/F highlight
Plug 'unblevable/quick-scope'
" {{{
  let g:qs_max_chars=120
  " let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
" }}}

" fuzzy find
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
" {{{
 let g:fzf_nvim_statusline = 0 " disable statusline overwriting
 let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.4 } }
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

" Search across project
Plug 'dyng/ctrlsf.vim'
" {{{
  let g:ctrlsf_ackprg = 'rg'
  nmap <leader>gg <Plug>CtrlSFPrompt
  nmap <leader>gv <Plug>CtrlSFVwordExec
  nmap <leader>gw <Plug>CtrlSFCCwordExec
  nmap <leader>gs <Plug>CtrlSFPwordPath
" }}}

"" Linting and fixing
Plug 'dense-analysis/ale'
" {{{
  let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \   'javascript': ['prettier'],
  \   'json': ['prettier'],
  \   'ruby': ['rubocop'],
  \   'elixir': ['mix_format'],
  \   'xml': ['xmllint'],
  \}
  let g:ale_ruby_rubocop_auto_correct_all = 1
  let g:ale_echo_msg_format = '[%linter%] %code: %%s'
  nmap <silent> <leader>ep <Plug>(ale_previous_wrap)
  nmap <silent> <leader>en <Plug>(ale_next_wrap)
  nmap <silent> <leader>ef <Plug>(ale_fix)
" }}}

" Plug 'ncm2/ncm2'
" " {{{
"   " inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
"   autocmd BufEnter * call ncm2#enable_for_buffer()
"   set completeopt=noinsert,menuone,noselect
"   set shortmess+=c
"   Plug 'ncm2/ncm2-neosnippet'
"   Plug 'ncm2/ncm2-bufword'
"   Plug 'fgrsnau/ncm2-otherbuf'
"   Plug 'ncm2/ncm2-path'
"   Plug 'svermeulen/ncm2-yoink'
" " }}}
" Plug 'roxma/nvim-yarp'
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" " {{{
"   let g:deoplete#enable_at_startup = 1
" " }}}
" Plug 'Shougo/neosnippet.vim'
" " {{{
"   let g:neosnippet#disable_runtime_snippets = {
"       \   '_' : 1,
"       \ }
"   let g:neosnippet#enable_snipmate_compatibility = 1
"   let g:neosnippet#snippets_directory='~/.config/nvim/plugged/vim-snippets/snippets'
"   imap <C-k>     <Plug>(neosnippet_expand_or_jump)
"   smap <C-k>     <Plug>(neosnippet_expand_or_jump)
"   xmap <C-k>     <Plug>(neosnippet_expand_target)
" " }}}
" Plug 'honza/vim-snippets'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
" {{{
  inoremap <silent><expr> <C-k> compe#confirm({ 'keys': '<CR>', 'mode': 'n', 'select': v:true })
  set completeopt=menuone,noselect
  set shortmess+=c
  let g:compe = {}
  let g:compe.source = {
    \ 'path': v:true,
    \ 'buffer': v:true,
    \ 'nvim_lsp': v:true,
    \ 'ultisnips': v:true,
    \ }
" }}}
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Yank highlight
Plug 'svermeulen/vim-yoink'

" Html tags
Plug 'alvan/vim-closetag'
" {{{
  let g:closetag_filenames = '*.html,*.vue,*.md,*.rb,*.mjml'
" }}}

"" Lightline
Plug 'itchyny/lightline.vim'
"{{{
  Plug 'maximbaz/lightline-ale'
  Plug 'skywind3000/asyncrun.vim'
  Plug 'albertomontesg/lightline-asyncrun'
  Plug 'ryanoasis/vim-devicons'
  Plug 'kyazdani42/nvim-web-devicons'

  function! Devicons_Filetype()
    " return winwidth(0) > 70 ? (strlen(&filetype) ? WebDevIconsGetFileTypeSymbol() . ' ' . &filetype : 'no ft') : ''
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
  endfunction
  function! Devicons_Fileformat()
    return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
  endfunction
  function! Tab_num(n) abort
    return a:n." \ue0bb"
  endfunction
  " function! GitStatus()
  "   return sy#repo#get_stats_decorated()
  "   " return {get(b:,'gitsigns_status','')}
  " endfunction


  let g:lightline = {}
  let g:lightline.colorscheme = 'onedark'
  let g:lightline.separator = { 'left': "\ue0b8", 'right': "\ue0be" }
  let g:lightline.subseparator = { 'left': "\ue0b9", 'right': "\ue0b9" }
  let g:lightline.tabline_separator = { 'left': "\ue0bc", 'right': "\ue0ba" }
  let g:lightline.tabline_subseparator = { 'left': "\ue0bb", 'right': "\ue0bb" }
  let g:lightline#ale#indicator_checking = "\uf110"
  let g:lightline#ale#indicator_warnings = "\uf529"
  let g:lightline#ale#indicator_errors = "\uf00d"
  let g:lightline#ale#indicator_ok = "\uf00c"
  let g:lightline_gitdiff#indicator_added = '+'
  let g:lightline_gitdiff#indicator_deleted = '-'
  let g:lightline_gitdiff#indicator_modified = '*'
  let g:lightline_gitdiff#min_winwidth = '70'
  let g:lightline#asyncrun#indicator_none = ''
  let g:lightline#asyncrun#indicator_run = 'Running...'
  let g:lightline.active = {
        \ 'left': [ [ 'mode', 'paste' ],
        \           [ 'readonly', 'filename', 'modified' ] ],
        \ 'right': [ [ 'lineinfo' ],
        \            [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
        \           [ 'asyncrun_status', 'devicons_filetype' ] ]
        \ }
  let g:lightline.inactive = {
        \ 'left': [ [ 'filename' , 'modified',  ]],
        \ 'right': [ [ 'devicons_filetype', 'lineinfo' ] ]
        \ }
  let g:lightline.tabline = {
        \ 'left': [ [ 'vim_logo', 'tabs' ] ],
        \ 'right': [ [ 'gitbranch' ] ]
        \ }
  let g:lightline.tab = {
        \ 'active': [ 'tabnum', 'filename', 'modified' ],
        \ 'inactive': [ 'tabnum', 'filename', 'modified' ] }
  let g:lightline.tab_component = {
        \ }
  let g:lightline.tab_component_function = {
        \ 'filename': 'lightline#tab#filename',
        \ 'modified': 'lightline#tab#modified',
        \ 'readonly': 'lightline#tab#readonly',
        \ 'tabnum': 'Tab_num'
        \ }
  let g:lightline.component = {
        \ 'bufinfo': '%{bufname("%")}:%{bufnr("%")}',
        \ 'vim_logo': "\ue7c5",
        \ 'mode': '%{lightline#mode()}',
        \ 'absolutepath': '%F',
        \ 'relativepath': '%f',
        \ 'filename': '%t',
        \ 'filesize': "%{HumanSize(line2byte('$') + len(getline('$')))}",
        \ 'fileencoding': '%{&fenc!=#""?&fenc:&enc}',
        \ 'fileformat': '%{&fenc!=#""?&fenc:&enc}[%{&ff}]',
        \ 'filetype': '%{&ft!=#""?&ft:"no ft"}',
        \ 'modified': '%M',
        \ 'bufnum': '%n',
        \ 'paste': '%{&paste?"PASTE":""}',
        \ 'readonly': '%R',
        \ 'charvalue': '%b',
        \ 'charvaluehex': '%B',
        \ 'percent': '%2p%%',
        \ 'percentwin': '%P',
        \ 'spell': '%{&spell?&spelllang:""}',
        \ 'lineinfo': '%2p%% %3l:%-2v',
        \ 'line': '%l',
        \ 'column': '%c',
        \ 'close': '%999X X ',
        \ 'winnr': '%{winnr()}'
        \ }
  let g:lightline.component_function = {
        \ 'gitbranch': 'FugitiveHead',
        \ 'devicons_filetype': 'Devicons_Filetype',
        \ 'devicons_fileformat': 'Devicons_Fileformat'
        \ }
  let g:lightline.component_expand = {
        \ 'linter_checking': 'lightline#ale#checking',
        \ 'linter_warnings': 'lightline#ale#warnings',
        \ 'linter_errors': 'lightline#ale#errors',
        \ 'linter_ok': 'lightline#ale#ok',
        \ 'asyncrun_status': 'lightline#asyncrun#status'
        \ }
  let g:lightline.component_type = {
        \ 'linter_warnings': 'warning',
        \ 'linter_errors': 'error'
        \ }
  set noshowmode
" }}}

" Wakatime
Plug 'wakatime/vim-wakatime'

" Commenting
Plug 'tpope/vim-commentary'

" Flash yanked
Plug 'machakann/vim-highlightedyank'
" {{{
  let g:highlightedyank_highlight_duration = 100
" }}}

" Advanced Split and Join
Plug 'AndrewRadev/splitjoin.vim'
" {{{
  let g:splitjoin_ruby_hanging_args = 0
  let g:splitjoin_ruby_curly_braces = 0
" }}}

" Git in gutter
" Plug 'nvim-lua/plenary.nvim'
" Plug 'lewis6991/gitsigns.nvim', { 'branch': 'main' }
Plug 'mhinz/vim-signify'
" {{{
  set signcolumn=yes
" }}}

Plug 'tpope/vim-fugitive'             " Awesome git plugin
Plug 'tpope/vim-endwise'              " autocomplete end
Plug 'tpope/vim-repeat'               " Enables dot command repeating for vim-surround, vim-unimpaired, etc
Plug 'tpope/vim-eunuch'               " file commands
Plug 'chrisbra/csv.vim'               " CSV tables
Plug 'tpope/vim-surround'             " Awesome surround plugin
Plug 'fcpg/vim-spotlightify'          " Advanced search via /
Plug 'whiteinge/diffconflicts'        " Better git mergetool
Plug 'wellle/targets.vim'             " Better object targets
Plug 'ryvnf/readline.vim'             " Readline style mappings for command-line mode in Vim
Plug 'psliwka/vim-smoothie'
Plug 'rhysd/clever-f.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'junegunn/vim-easy-align'
" {{{
  xmap <leader>a <Plug>(EasyAlign)
  nmap <leader>a <Plug>(EasyAlign)
" }}}

Plug 'voldikss/vim-floaterm'
" {{{
  noremap <silent> <leader>fg :FloatermNew --height=0.9 --width=0.9 lazygit<CR>
" }}}

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

" Other
Plug 'pangloss/vim-javascript'
Plug 'slim-template/vim-slim'
Plug 'amadeus/vim-mjml'
Plug 'elixir-editors/vim-elixir'
Plug 'tbastos/vim-lua'

call plug#end()

lua require('lsp')
" lua require('gitsigns').setup()

" Theme
set termguicolors
set background=dark
colorscheme onedark

" Settings
set noswapfile

set inccommand=split
set regexpengine=1
set gdefault

" default updatetime 4000ms is not good for async update
set updatetime=100

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
map <silent> <leader>nr :so ~/.config/nvim/init.vim<cr>
map <silent> <leader>no :e ~/.config/nvim/init.vim<cr>

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
cnoreabbrev Xa xa
cnoreabbrev t tabe
cnoreabbrev qt tabclose
nnoremap q: :q<CR>

" Current file things
nmap <leader>os :let @1 = expand("%")<CR> :sav <C-R>1
nmap <leader>ok :let @1 = expand("%:h")<CR> :Mkdir! <C-R>1
nmap <leader>or :let @1 = expand("%:t")<CR> :Rename <C-R>1
nmap <leader>om :let @1 = expand("%")<CR> :Move <C-R>1
nmap <leader>od :Delete

" Copy dir/file/line to clipboard
map <silent> <leader>sl <Esc>:let @*=expand("%") . ":" . line(".")<CR>
map <silent> <leader>sf <Esc>:let @*=expand("%")<CR>
map <silent> <leader>sd <Esc>:let @*=expand("%:h")<CR>

" Saner command line history
cnoremap <c-n>  <down>
cnoremap <c-p>  <up>

" Don't lose selection when shifting sidewards
xnoremap <  <gv
xnoremap >  >gv

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
nmap <S-F1> 1gt
nmap <S-F2> 2gt
nmap <S-F3> 3gt
nmap <S-F4> 4gt
nmap <S-F5> 5gt
nmap <S-F6> 6gt
nmap <S-F7> 7gt
nmap <S-F8> 8gt
nmap <S-F9> 9gt

" Intelligent windows resizing using ctrl + arrow keys
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
" map <Leader>b :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
" \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
" \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" File mappings
autocmd! BufRead,BufNewFile *.slimeex     setfiletype slim
