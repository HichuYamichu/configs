set bg=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name="Froob"

hi Normal     ctermfg=254 
hi Comment    ctermfg=60
hi Constant   ctermfg=254
hi Identifier ctermfg=254
hi Statement  ctermfg=254
hi Type       ctermfg=254
hi Special    ctermfg=117

hi WarningMsg ctermfg=231 ctermbg=none cterm=undercurl guisp=#ff5f87
hi ErrorMsg   ctermfg=Red ctermbg=none

hi String         ctermfg=85
hi Character      ctermfg=86
hi Number         ctermfg=209
hi Boolean        ctermfg=228
hi Float          ctermfg=209
hi Function       ctermfg=68
hi Repeat         ctermfg=177
hi Conditional    ctermfg=177
hi Label          ctermfg=117
hi Operator       ctermfg=254
hi Keyword        ctermfg=177
hi Include        ctermfg=177
hi Define         ctermfg=177
hi Macro          ctermfg=68
hi Typedef        ctermfg=254
hi Delimiter      ctermfg=117
hi SpecialComment ctermfg=60

hi ColorColumn  ctermbg=242
hi LineNr       ctermfg=243
hi LineNrAbove  ctermfg=243
hi LineNrBelow  ctermfg=243
hi CursorLineNr ctermfg=254

hi Menu       ctermfg=254
hi WildMenu   ctermfg=254 ctermbg=236 cterm=none
hi Pmenu      ctermfg=254 ctermbg=233 
hi PmenuSel   ctermfg=254 ctermbg=240
hi PmenuSbar  ctermfg=254 ctermbg=241
hi PmenuThumb ctermfg=254 ctermbg=236
hi CursorLine ctermbg=234 cterm=none
hi VertSplit  ctermfg=0   ctermbg=0
" hi Title      ctermfg=0   ctermbg=0

hi Folded     ctermfg=248 ctermbg=none cterm=bold
hi FoldColumn ctermfg=248 ctermbg=none cterm=bold
hi SignColumn ctermbg=none

hi rustStorage       ctermfg=177
hi rustLifetime      ctermfg=254
hi rustSigil         ctermfg=117
hi rustFoldBraces    ctermfg=117
hi rustModPath       ctermfg=254
hi rustModPathSep    ctermfg=254
hi rustDerive        ctermfg=254
hi rustAttribute     ctermfg=254
hi rustUnsafeKeyword ctermfg=177
hi rustSelf			 ctermfg=213

hi CocWarningSign  ctermfg=217
hi CocHintSign		  ctermfg=87
hi CocHighlightText ctermbg=235

