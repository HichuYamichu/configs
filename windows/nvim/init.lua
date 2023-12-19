vim.opt.shell = "pwsh"
vim.opt.shellxquote = ""
vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
vim.opt.shellquote = ''
vim.opt.shellpipe = '| Out-File -Encoding UTF8 %s'
vim.opt.shellredir = '| Out-File -Encoding UTF8 %s'

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system(
        {
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
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
    'rust-lang/rust.vim',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'tpope/vim-commentary',
})

vim.cmd([[set fillchars+=vert:\ ]])
vim.cmd([[set wrap smoothscroll ]])
-- vim.cmd([[autocmd FileType netrw autocmd BufLeave <buffer> if &filetype == 'netrw' | :bd | endif]])
vim.cmd([[autocmd FileType netrw setl bufhidden=wipe]])
vim.cmd([[let g:netrw_fastbrowse = 0]])
vim.cmd([[filetype plugin indent on]])
vim.cmd([[colorscheme froob]])
vim.cmd([[set termguicolors ]])
vim.cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])
vim.cmd(
    [[au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])

vim.cmd([[
command! -bang -nargs=? -complete=dir Files
\ call fzf#vim#files(<q-args>, {'source': 'rg --files --hidden',
\                               'options': ['--tiebreak=index', '--preview', 'bat --color=always --style=numbers {}']}, <bang>0)]])

vim.api.nvim_exec([[
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}
augroup end
]], false)

local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
    },
    mapping = {
        ['<C-y>'] = cmp.config.disable,
        ['<TAB>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true
        }),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = false
        }),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<Down>'] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    local keys = vim.api.nvim_replace_termcodes("<Down>", true, false, true)
                    vim.api.nvim_feedkeys(keys, 'n', true)
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end
        }),
        ['<Up>'] = cmp.mapping({
            c = function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    local keys = vim.api.nvim_replace_termcodes("<Up>", true, false, true)
                    vim.api.nvim_feedkeys(keys, 'n', true)
                end
            end,
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end
        }),
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp", },
        { name = "luasnip",  },
    },{
        { name = "buffer",   },
    }),
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(args.buf, false)
        end
        
        local opts = { buffer = args.buf }
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration({reuse_win = true})<CR>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition({reuse_win = true})<CR>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation({reuse_win = true})<CR>', opts)
        vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = true})<CR>', opts)
        vim.keymap.set('n', '<C-i>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.keymap.set('n', '<C-m>', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        vim.keymap.set('n', '<C-n>', '<cmd>lua vim.diagnostic.hover()<CR>', opts)
    end
})
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        signs = {
            severity = {
                vim.diagnostic.severity.WARN,
                vim.diagnostic.severity.ERROR,
            }
        },
        underline = {
            severity = {
                vim.diagnostic.severity.ERROR,
            }
        },
        update_in_insert = false
    }
)

vim.diagnostic.config({ float = { border = "rounded" } })

require('lspconfig').tsserver.setup {
}

require('lspconfig').gopls.setup {
}

require('lspconfig').rust_analyzer.setup {
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
                limit = 10,
                postfix = {
                    enable = false
                }
            }
        },
        inlayHints = {
            chainingHints = true,
            parameterHints = true,
            typeHints = true
        }
    }
}

vim.api.nvim_set_hl(0, '@lsp.type.macro.rust', {})

vim.o.completeopt = 'menu,menuone,noselect'
vim.g.mapleader = " "
vim.g.nofoldenable = true
vim.g.noshowmode = true
vim.g.nojoinspaces = true

vim.opt.number = true
vim.opt.autoindent = true
vim.opt.timeoutlen = 300
vim.opt.encoding = 'utf-8'
vim.opt.scrolloff = 10
vim.opt.hidden = true
vim.opt.signcolumn = 'yes'
vim.opt.clipboard = 'unnamedplus'
vim.opt.cursorline = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.undodir = '/home/hy/.vimdid'
vim.opt.undofile = true

vim.opt.wildmenu = true
vim.opt.wildmode = 'list:longest'
vim.opt.wildignore =
'.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor'

vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true

vim.opt.cmdheight = 1
vim.opt.updatetime = 300

vim.opt.number = true
vim.opt.colorcolumn = '100'
vim.opt.showcmd = true
vim.opt.mouse = 'a'

local map = vim.api.nvim_set_keymap
local default_opts = {
    noremap = true,
    silent = true
}

_G.inlay_hints_enabled = false
function ToggleInlayHints()
    _G.inlay_hints_enabled = not _G.inlay_hints_enabled
    vim.lsp.inlay_hint.enable(0, _G.inlay_hints_enabled)
end

map('n', '<leader>o', ':lua ToggleInlayHints()<CR>', default_opts)
map('n', '<leader>w', ':w<CR>', default_opts)
map('n', '<leader>q', ':q<CR>', default_opts)
map('n', '<leader>a', ':bd<CR>', default_opts)
map('n', '<leader>s', ':Rg<CR>', { noremap = true })
map('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "\" <CR>', { noremap = true })
map('n', '<leader><leader>', '<c-^>', { noremap = true })

map('n', '<leader>j', ':wincmd j<CR>', { noremap = true })
map('n', '<leader>h', ':wincmd h<CR>', { noremap = true })
map('n', '<leader>k', ':wincmd k<CR>', { noremap = true })
map('n', '<leader>l', ':wincmd l<CR>', { noremap = true })

map('i', ',', ',<C-g>u', default_opts)
map('i', '.', '.<C-g>u', default_opts)
map('i', '!', '!<C-g>u', default_opts)
map('i', '?', '?<C-g>u', default_opts)
map('i', ' ', ' <C-g>u', default_opts)

map('i', '<C-z>', '<C-g>u<C-O>u', { noremap = true })
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

map('v', '<C-c>', 'y', { noremap = true })
map('n', '<q>', '<C-v', default_opts)

map('', '<C-h>', '0', default_opts)
map('', '<C-l>', '$', default_opts)

map('', '<C-p>', ':Files<CR>', { noremap = true })
map('', '<C-o>', ':Buffers<CR>', { noremap = true })

map('n', '<C-a>', ':%', { noremap = true })
map('v', '<C-_>', '<Plug>Commentary', { noremap = true })

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


