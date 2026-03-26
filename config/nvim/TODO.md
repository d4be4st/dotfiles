# Neovim Plugin TODO

## High Impact — Easy Wins

- [x] Replace `nvim-cmp` + all cmp sources + `lspkind-nvim` with **`blink.cmp`** — faster, batteries-included, no separate source plugins needed
- [x] Replace `feline.nvim` with **`lualine.nvim`** — feline fork is going nowhere, lualine is the standard
- [x] Replace `fyler.nvim` with **`oil.nvim`** — community darling, edit filesystem like a buffer (was already in config commented out)
- [x] Delete `none-ls.nvim` — sources block is empty, it's doing nothing
- [x] Delete `nvim-treesitter/playground` — use `:InspectTree` instead (built into Neovim 0.9+)
- [x] Delete `mini.comment` — Neovim 0.10+ ships native `gc` operator, this is redundant
- [x] Replace `copilot.vim` with **`copilot.lua`** — the Lua rewrite is faster and integrates with blink.cmp

## Worth Exploring

- [x] **`snacks.nvim` notifier + picker** — replaced telescope with snacks.picker, added snacks.notifier
- [x] **`grug-far.nvim`** — replaced `nvim-spectre`
- [-] **`Neogit`** — skipped, using diffview for interactive git
- [x] **`todo-comments.nvim`** — added (`]t`/`[t` navigate, `<leader>fT` search)
- [-] **`nvim-dap-virtual-text`** — skipped, not using DAP
- [ ] **`codecompanion.nvim`** — currently the top community pick for multi-model AI chat + inline edits

## Already on the Latest

- `catppuccin` — #1 most used colorscheme in the ecosystem
- `gitsigns.nvim` — still the standard
- `diffview.nvim` — still the standard
- `flash.nvim` — still the shit, no real competitor
- `which-key.nvim` — still the standard
- `nvim-treesitter` + textobjects — still the only option
- `nvim-dap` + `dap-ui` — still the only real debugger option
- `mini.surround` — solid, `nvim-surround` is the alternative if more power needed
- `noice.nvim` — still king for full UI replacement
- `ssr.nvim` — still the only structural search & replace option
- `treesj` — still the best split/join
- `overseer.nvim` — still the best task runner
- `claudecode.nvim` — cutting edge
- LSP setup — already using `vim.lsp.config()` + `vim.lsp.enable()` (Neovim 0.11 native), ahead of most configs
