local cmd = vim.cmd
local exec = vim.api.nvim_exec
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local map = vim.api.nvim_set_keymap
local default_opts = {noremap = true, silent = true}

local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'ObserverOfTime/coloresque.vim'
Plug 'airblade/vim-rooter'
Plug('junegunn/fzf', { dir = '~/.fzf', ['do'] = './install --all' })
Plug 'junegunn/fzf.vim'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'dag/vim-fish'
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'plasticboy/vim-markdown'
Plug 'simrat39/rust-tools.nvim'
Plug 'rust-lang/rust.vim'
Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
Plug 'neovimhaskell/haskell-vim'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

vim.call('plug#end')

cmd('colorscheme froob')
cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])
cmd([[au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])

exec([[
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup end
]], false)

local cmp = require'cmp'
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
	["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp', max_item_count = 10 },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer', max_item_count = 3 },
  }),
  experimental = {
    ghost_text = true,
  }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
local nvim_lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Example custom server
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

require('lspconfig').sumneko_lua.setup {
  cmd = { vim.fn.getenv 'HOME' .. '/dev/extern/lua-language-server/bin/Linux/lua-language-server' },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

require('lspconfig').hls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "haskell-language-server-wrapper", "--lsp" },
    filetypes = { "haskell", "lhaskell" },
    settings = {
      haskell = {
        formattingProvider = "brittany"
      }
    }
}

require('lspconfig').tsserver.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

require('lspconfig').rust_analyzer.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      completion = {
        addCallParenthesis = false,
        postfix = {
          enable = false,
        },
      },
    },
  },
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
        severity = 'Error'
    },
    signs = {
        severity = 'Error'
    },
    underline = {
        severity = 'Error'
    },
    update_in_insert = false,
  }
)

local luasnip = require 'luasnip'
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function goto_definition(split_cmd)
local util = vim.lsp.util
local log = require("vim.lsp.log")
local api = vim.api

-- note, this handler style is for neovim 0.5.1/0.6, if on 0.5, call with function(_, method, result)
local handler = function(_, result, ctx)
  if result == nil or vim.tbl_isempty(result) then
    local _ = log.info() and log.info(ctx.method, "No location found")
    return nil
  end

  if split_cmd then
    vim.cmd(split_cmd)
  end

  if vim.tbl_islist(result) then
    util.jump_to_location(result[1])

    if #result > 1 then
      util.set_qflist(util.locations_to_items(result))
      api.nvim_command("copen")
      api.nvim_command("wincmd p")
    end
  else
    util.jump_to_location(result)
  end
end

return handler
end

vim.lsp.handlers["textDocument/definition"] = goto_definition('vs')

vim.o.completeopt = 'menu,menuone,noselect'
g.mapleader = " "
g.nofoldenable = true
g.noshowmode = true
g.nojoinspaces = true

opt.number = true
opt.autoindent = true
opt.timeoutlen = 300
opt.encoding='utf-8'
opt.scrolloff = 10
opt.hidden = true
opt.printencoding = 'utf-8'
opt.signcolumn = 'yes'
opt.clipboard = 'unnamedplus'
opt.cursorline = true

opt.splitright = true
opt.splitbelow = true

opt.undodir = '/home/hy/.vimdid'
opt.undofile = true

opt.wildmenu = true
opt.wildmode = 'list:longest'
opt.wildignore ='.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor'

opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.expandtab = true

opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.gdefault = true

opt.cmdheight = 1
opt.updatetime = 300

opt.number = true
opt.colorcolumn = '100'
opt.showcmd = true
opt.mouse = 'a'

map('i', ',', ',<C-g>u', {noremap = true})
map('i', '.', '.<C-g>u', {noremap = true})
map('i', '!', '!<C-g>u', {noremap = true})
map('i', '?', '?<C-g>u', {noremap = true})

map('i', '<C-v>', '<C-r><C-p>+', default_opts)
map('c', '<C-v>', '<C-r>"', default_opts)
map('v', 'p', '"_dP', default_opts)

map('n', '<C-j>', '<Esc>', {noremap = true})
map('i', '<C-j>', '<Esc>', {noremap = true})
map('v', '<C-j>', '<Esc>', {noremap = true})
map('s', '<C-j>', '<Esc>', {noremap = true})
map('x', '<C-j>', '<Esc>', {noremap = true})
map('c', '<C-j>', '<C-c>', {noremap = true})
map('o', '<C-j>', '<Esc>', {noremap = true})
map('l', '<C-j>', '<Esc>', {noremap = true})
map('t', '<C-j>', '<Esc>', {noremap = true})

map('n', '<C-k>', '<Esc>', {noremap = true})
map('i', '<C-k>', '<Esc>', {noremap = true})
map('v', '<C-k>', '<Esc>', {noremap = true})
map('s', '<C-k>', '<Esc>', {noremap = true})
map('x', '<C-k>', '<Esc>', {noremap = true})
map('c', '<C-k>', '<Esc>', {noremap = true})
map('o', '<C-k>', '<Esc>', {noremap = true})
map('l', '<C-k>', '<Esc>', {noremap = true})
map('t', '<C-k>', '<C-\\><C-n>', {noremap = true})

map('n', '<C-c>', '<Esc>', {noremap = true})
map('i', '<C-c>', '<Esc>', {noremap = true})
map('v', '<C-c>', '<Esc>', {noremap = true})
map('s', '<C-c>', '<Esc>', {noremap = true})
map('x', '<C-c>', '<Esc>', {noremap = true})
map('c', '<C-c>', '<C-c>', {noremap = true})
map('o', '<C-c>', '<Esc>', {noremap = true})
map('l', '<C-c>', '<Esc>', {noremap = true})
map('t', '<C-c>', '<Esc>', {noremap = true})

map('n', '<leader>w', ':w<CR>', default_opts)

map('', '<C-h>', '0', default_opts)
map('', '<C-l>', '$', default_opts)

map('v', 'H', 'b', {noremap = true})
map('n', 'H', 'b', {noremap = true})

map('v', 'L', 'e', {noremap = true})
map('n', 'L', 'e', {noremap = true})

map('n', 'J', ':m .+1<CR>==', {noremap = true})
map('n', 'K', ':m .-2<CR>==', {noremap = true})
map('v', 'J', ':m \'>+1<CR>gv=gv', {noremap = true})
map('v', 'K', ':m \'<-2<CR>gv=gv', {noremap = true})

map('c', '%s/', '%sm/', {noremap = true})

map('x', '>', '>gv', {noremap = true})
map('x', '<', '<gv', {noremap = true})

map('n', '<left>', ':bp<CR>', {noremap = true})
map('n', '<right>', ':bn<CR>', {noremap = true})

map('', '<C-p>', ':Files<CR>', {noremap = true})
map('', '<C-o>', ':Buffers<CR>', {noremap = true})

map('n', '<leader>s', ':Rg<CR>', {noremap = true})
map('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>', {noremap = true})
map('n', '<leader><leader>', '<c-^>', {noremap = true})

map('n', '<leader>j', ':wincmd j<CR>', {noremap = true})
map('n', '<leader>h', ':wincmd h<CR>', {noremap = true})
map('n', '<leader>k', ':wincmd k<CR>', {noremap = true})
map('n', '<leader>l', ':wincmd l<CR>', {noremap = true})

map('n', '<C-n>', ':lua vim.diagnostic.disable()<CR>', default_opts)
map('n', '<C-m>', ':lua vim.diagnostic.enable()<CR>', default_opts)
