# IP6 Documentation
## language server_configurations
1. install `ltex-ls` using Mason
2. install `texlab` using Mason


### Ltex-ls setup
1. Install it using Mason
2. Setup like: [Documentation](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ltex)
an example setup with a custom dictionary:
```lua
local lspConfig = require('lspconfig')
lspConfig["ltex"].setup({
  settings = {
    ltex = {
      language = "en-GB",
      dictionary = {
        ['en-GB'] = {"Andri", "Wild", "Tobias", "Wyss", "Kolibri" }
      }
    }
  }
})
```

## vimtex setup
Keymappings lookup mittels: `help vimtex-default-mappings`

### my vimtex config
```lua 
vim.api.nvim_set_var('maplocalleader', ' ')
-- This is necessary for VimTeX to load properly. The "indent" is optional.
-- Note that most plugin managers will do this automatically.
vim.cmd('filetype plugin indent on')
-- opens quickfix only if there are errors
vim.g.vimtex_quickfix_open_on_warning = 0
-- open quickfix window not automatically
vim.g.tex_flavor='latex'
-- show some latex symbols only when on corresponding line
vim.opt.conceallevel = 1
vim.g.tex_conceal = 'abdmg'

-- This enables Vim's and neovim's syntax-related features. Without this, some
-- VimTeX features will not work (see ":help vimtex-requirements" for more
-- info).
-- vim.cmd('syntax enable')

-- Viewer options: One may configure the viewer either by specifying a built-in
-- viewer method:
vim.g.vimtex_view_method = 'skim'

-- for tex files width to 80
vim.cmd([[
  augroup WrapLineInTeXFile
    autocmd!
    autocmd FileType tex setlocal tw=79
  augroup END
]])

```
