set bg=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name="Froob"

hi Normal     ctermbg=None guibg=None
hi Comment    ctermfg=60 guifg=#5f5f87 guibg=None
hi Constant   ctermfg=254 guifg=#e4e4e4 guibg=None
hi Identifier ctermfg=254 guifg=#e4e4e4 guibg=None
hi Statement  ctermfg=254 guifg=#e4e4e4 guibg=None
hi Type       ctermfg=254 guifg=#e4e4e4 guibg=None
hi Special    ctermfg=117 guifg=#87d7ff guibg=None

hi WarningMsg ctermfg=231 ctermbg=none cterm=undercurl guisp=#ff5f87 guifg=#ff5f87 guibg=None
hi ErrorMsg   ctermfg=160 ctermbg=none guifg=#d70000 guibg=None

hi String         ctermfg=85 guifg=#5fffaf guibg=None
hi Character      ctermfg=86 guifg=#5fffd7 guibg=None
hi Number         ctermfg=209 guifg=#ff875f guibg=None
hi Boolean        ctermfg=228 guifg=#ffff87 guibg=None
hi Float          ctermfg=209 guifg=#ff875f guibg=None
hi Function       ctermfg=68 guifg=#5f87d7 guibg=None
hi Repeat         ctermfg=177 guifg=#d787ff guibg=None
hi Conditional    ctermfg=177 guifg=#d787ff guibg=None
hi Label          ctermfg=117 guifg=#87d7ff guibg=None
hi Operator       ctermfg=254 guifg=#e4e4e4 guibg=None
hi Keyword        ctermfg=177 guifg=#d787ff guibg=None
hi Include        ctermfg=177 guifg=#d787ff guibg=None
hi Define         ctermfg=177 guifg=#d787ff guibg=None
hi Macro          ctermfg=68 guifg=#5f87d7 guibg=None
hi Typedef        ctermfg=254 guifg=#e4e4e4 guibg=None
hi Delimiter      ctermfg=117 guifg=#87d7ff guibg=None
hi SpecialComment ctermfg=60 guifg=#5f5f87 guibg=None

hi ColorColumn  ctermbg=236 guibg=#303030
hi LineNr       ctermfg=243 guifg=#767676
hi LineNrAbove  ctermfg=243 guifg=#767676
hi LineNrBelow  ctermfg=243 guifg=#767676
hi CursorLineNr ctermfg=254 cterm=none guifg=#e4e4e4 guibg=None
hi CursorLine ctermbg=233 cterm=none guibg=#121212
hi Cursor       ctermbg=161 guibg=#d7005f
hi IncSearch    ctermbg=35 guibg=#00af5f

hi Menu       ctermfg=254 guifg=#e4e4e4
hi WildMenu   ctermfg=254 ctermbg=236 cterm=none guifg=#e4e4e4 guibg=#363636
hi Pmenu      ctermfg=254 ctermbg=233 guifg=#e4e4e4 guibg=#121212
hi PmenuSel   ctermfg=254 ctermbg=240 guifg=#e4e4e4 guibg=#585858
hi PmenuSbar  ctermfg=254 ctermbg=241 guifg=#e4e4e4 guibg=#626262
hi PmenuThumb ctermfg=254 ctermbg=236 guifg=#e4e4e4 guibg=#303030
hi MatchParen ctermfg=15 ctermbg=147 guifg=#ffffff guibg=#afafff

hi Folded     ctermfg=248 ctermbg=none cterm=bold guifg=#a8a8a8 guibg=None gui=bold
hi FoldColumn ctermfg=248 ctermbg=none cterm=bold guifg=#a8a8a8 guibg=None gui=bold
hi SignColumn ctermbg=none guibg=None

hi DiagnosticError         ctermfg=204 guifg=#ff5f87
hi DiagnosticFloatingError ctermfg=204 guifg=#ff5f87
hi DiagnosticWarn          ctermfg=215 guifg=#ffaf5f
hi DiagnosticFloatingWarn  ctermfg=215 guifg=#ffaf5f

hi NvimInternalError ctermfg=204 guifg=#ff5f87

hi rustStorage       ctermfg=177 guifg=#d787ff
hi rustLifetime      ctermfg=254 guifg=#e4e4e4
hi rustSigil         ctermfg=117 guifg=#87d7ff
hi rustFoldBraces    ctermfg=117 guifg=#87d7ff
hi rustModPath       ctermfg=254 guifg=#e4e4e4
hi rustModPathSep    ctermfg=254 guifg=#e4e4e4
hi rustDerive        ctermfg=254 guifg=#e4e4e4
hi rustAttribute     ctermfg=254 guifg=#e4e4e4
hi rustUnsafeKeyword ctermfg=177 guifg=#d787ff
hi rustSelf          ctermfg=213 guifg=#ff87ff

hi haskellOperators  ctermfg=117 guifg=#87d7ff
hi haskellWhere      ctermfg=177 guifg=#d787ff