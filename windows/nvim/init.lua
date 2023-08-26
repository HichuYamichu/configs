local cmd = vim.cmd
local exec = vim.api.nvim_exec
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local map = vim.api.nvim_set_keymap
local default_opts = {
    noremap = true,
    silent = true
}

opt.shell = "pwsh"
opt.shellxquote = ""
opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
opt.shellquote = ''
opt.shellpipe = '| Out-File -Encoding UTF8 %s'
opt.shellredir = '| Out-File -Encoding UTF8 %s'

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system(
        {
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath
        })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    'itchyny/lightline.vim',
    'ObserverOfTime/coloresque.vim',
    'airblade/vim-rooter',
    { 'junegunn/fzf', build = '.\\install.ps1' },
    'junegunn/fzf.vim',
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'cespare/vim-toml',
    'stephpy/vim-yaml',
    'plasticboy/vim-markdown',
    'simrat39/rust-tools.nvim',
    'rust-lang/rust.vim',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    -- {
    --     'zbirenbaum/copilot.lua',
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    -- },
    -- {
    --     'zbirenbaum/copilot-cmp',
    --     config = function()
    --         require('copilot').setup({
    --             suggestion = {
    --                 enabled = false,
    --             },
    --             panel = {
    --                 enabled = false
    --             }
    --         })
    --     end
    -- }
})

cmd('colorscheme froob')
cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])
cmd(
    [[au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])
cmd([[command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)]])

exec([[
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup end
]], false)

local cmp = require 'cmp'
local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
    },
    mapping = {
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<CR>'] = cmp.mapping.confirm({
            select = true
        }),
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
                cmp.select_next_item({
                    behavior = cmp.SelectBehavior.Select
                })
            else
                fallback()
            end
        end, { "i", "s" })
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp", group_index = 2 },
        { name = "copilot",  group_index = 2 },
        { name = "luasnip",  group_index = 2 },
        { name = "buffer",   group_index = 2 },
        { name = "nvim_lua", group_index = 2 },
        { name = "path",     group_index = 2 },
    }),
    experimental = {
        ghost_text = true
    }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    sources = { {
        name = 'buffer'
    } }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({ {
        name = 'path'
    } }, { {
        name = 'cmdline'
    } })
})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = {
        noremap = true,
        silent = true
    }

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
    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
    buf_set_keymap('n', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
end

require('lspconfig').hls.setup {
    on_attach = on_attach,
    cmd = { "haskell-language-server-wrapper", "--lsp" },
    filetypes = { "haskell", "lhaskell" },
    settings = {
        haskell = {
            formattingProvider = "brittany"
        }
    }
}

require('lspconfig').tsserver.setup {
    on_attach = on_attach
}

require('lspconfig').rust_analyzer.setup {
    on_attach = on_attach,
    flags = {
        debounce_text_changes = 150
    },
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true
            },
            completion = {
                addCallParenthesis = false,
                postfix = {
                    enable = false
                }
            }
        }
    }
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
        severity = 'Error'
    },
    signs = {
        severity = 'Error'
    },
    underline = {
        severity = 'Error'
    },
    update_in_insert = false
})

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
opt.encoding = 'utf-8'
opt.scrolloff = 10
opt.hidden = true
-- opt.printencoding = 'utf-8'
opt.signcolumn = 'yes'
opt.clipboard = 'unnamedplus'
opt.cursorline = true

opt.splitright = true
opt.splitbelow = true

opt.undodir = '/home/hy/.vimdid'
opt.undofile = true

opt.wildmenu = true
opt.wildmode = 'list:longest'
opt.wildignore =
'.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor'

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

map('i', ',', ',<C-g>u', { noremap = true })
map('i', '.', '.<C-g>u', { noremap = true })
map('i', '!', '!<C-g>u', { noremap = true })
map('i', '?', '?<C-g>u', { noremap = true })

map('i', '<C-v>', '<C-r><C-p>+', default_opts)
map('c', '<C-v>', '<C-r>"', default_opts)
map('v', 'p', '"_dP', default_opts)

map('n', '<C-j>', '<Esc>', { noremap = true })
map('i', '<C-j>', '<Esc>', { noremap = true })
map('v', '<C-j>', '<Esc>', { noremap = true })
map('s', '<C-j>', '<Esc>', { noremap = true })
map('x', '<C-j>', '<Esc>', { noremap = true })
map('c', '<C-j>', '<C-c>', { noremap = true })
map('o', '<C-j>', '<Esc>', { noremap = true })
map('l', '<C-j>', '<Esc>', { noremap = true })
map('t', '<C-j>', '<Esc>', { noremap = true })

map('n', '<C-k>', '<Esc>', { noremap = true })
map('i', '<C-k>', '<Esc>', { noremap = true })
map('v', '<C-k>', '<Esc>', { noremap = true })
map('s', '<C-k>', '<Esc>', { noremap = true })
map('x', '<C-k>', '<Esc>', { noremap = true })
map('c', '<C-k>', '<Esc>', { noremap = true })
map('o', '<C-k>', '<Esc>', { noremap = true })
map('l', '<C-k>', '<Esc>', { noremap = true })
map('t', '<C-k>', '<C-\\><C-n>', { noremap = true })

map('n', '<C-c>', '<Esc>', { noremap = true })
map('i', '<C-c>', '<Esc>', { noremap = true })
map('v', '<C-c>', '<Esc>', { noremap = true })
map('s', '<C-c>', '<Esc>', { noremap = true })
map('x', '<C-c>', '<Esc>', { noremap = true })
map('c', '<C-c>', '<C-c>', { noremap = true })
map('o', '<C-c>', '<Esc>', { noremap = true })
map('l', '<C-c>', '<Esc>', { noremap = true })
map('t', '<C-c>', '<Esc>', { noremap = true })

map('n', '<leader>w', ':w<CR>', default_opts)

map('', '<C-h>', '0', default_opts)
map('', '<C-l>', '$', default_opts)

map('v', 'H', 'b', { noremap = true })
map('n', 'H', 'b', { noremap = true })

map('v', 'L', 'e', { noremap = true })
map('n', 'L', 'e', { noremap = true })

map('n', 'J', ':m .+1<CR>==', { noremap = true })
map('n', 'K', ':m .-2<CR>==', { noremap = true })
map('v', 'J', ':m \'>+1<CR>gv=gv', { noremap = true })
map('v', 'K', ':m \'<-2<CR>gv=gv', { noremap = true })

map('c', '%s/', '%sm/', { noremap = true })

map('x', '>', '>gv', { noremap = true })
map('x', '<', '<gv', { noremap = true })

map('n', '<left>', ':bp<CR>', { noremap = true })
map('n', '<right>', ':bn<CR>', { noremap = true })

map('', '<C-p>', ':Files<CR>', { noremap = true })
map('', '<C-o>', ':Buffers<CR>', { noremap = true })

map('n', '<leader>s', ':Rg<CR>', { noremap = true })
map('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>', { noremap = true })
map('n', '<leader><leader>', '<c-^>', { noremap = true })

map('n', '<leader>j', ':wincmd j<CR>', { noremap = true })
map('n', '<leader>h', ':wincmd h<CR>', { noremap = true })
map('n', '<leader>k', ':wincmd k<CR>', { noremap = true })
map('n', '<leader>l', ':wincmd l<CR>', { noremap = true })

map('n', '<C-n>', ':lua vim.diagnostic.disable()<CR>', default_opts)
map('n', '<C-m>', ':lua vim.diagnostic.enable()<CR>', default_opts)
