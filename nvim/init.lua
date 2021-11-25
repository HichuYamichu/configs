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
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'windwp/nvim-autopairs'
Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
Plug 'windwp/nvim-ts-autotag'
Plug 'simrat39/rust-tools.nvim'
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'rust-lang/rust.vim'
Plug 'dag/vim-fish'
Plug 'plasticboy/vim-markdown'
Plug('fatih/vim-go', { ['do'] = ':GoUpdateBinaries' })
Plug 'neovimhaskell/haskell-vim'
Plug 'andrejlevkovitch/vim-lua-format'

vim.call('plug#end')

cmd('colorscheme froob') 
cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])
cmd([[au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])
cmd([[autocmd BufWrite *.lua call LuaFormat()]])

exec([[
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup end
]], false)

local nvim_lsp = require('lspconfig')

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = false,
        virtual_text = false,
        underline = false
    }
)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local servers = { 'rust_analyzer', 'html', 'tsserver', 'hls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

local luasnip = require 'luasnip'

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require 'cmp'
cmp.setup {
    completion = {
        -- completeopt = 'menu,menuone,noinsert',
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        },
        sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

require('nvim-autopairs').setup({
    disable_filetype = { "rust", "go", "js" },
})

require("nvim-autopairs.completion.cmp").setup({
    map_cr = true, --  map <CR> on insert mode
    map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
    auto_select = false, -- automatically select the first item
    insert = false, -- use insert confirm behavior instead of replace
    map_char = { -- modifies the function or method delimiter by filetypes
        all = '(',
        tex = '{'
    }
})

require('nvim-ts-autotag').setup()

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
map('v', 'K', ':m \'>-2<CR>gv=gv', {noremap = true})

map('c', '%s/', '%sm/', {noremap = true})

map('x', '>', '>gv', {noremap = true})
map('x', '<', '<gv', {noremap = true})

map('n', '<left>', ':bp<CR>', {noremap = true})
map('n', '<right>', ':bn<CR>', {noremap = true})

map('', '<C-p>', ':Files<CR>', {noremap = true})
map('', '<C-o>', ':Buffers<CR>', {noremap = true})

map('n', '<C-f>', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})<CR>', {noremap = true})

map('n', '<silent> g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', {noremap = true})
map('n', '<silent> g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', {noremap = true})

map('n', '<leader>s', ':Rg<CR>', {noremap = true})

map('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>', {noremap = true})

map('n', '<leader><leader>', '<c-^>', {noremap = true})

map('n', '<leader>,', ':set invlist<cr>',{noremap = true})

map('n', '<leader>h', ':wincmd h<CR>', {noremap = true})
map('n', '<leader>j', ':wincmd j<CR>', {noremap = true})
map('n', '<leader>k', ':wincmd k<CR>', {noremap = true})
map('n', '<leader>l', ':wincmd l<CR>', {noremap = true})
