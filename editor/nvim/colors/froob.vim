set bg=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name="Froob"

hi Normal     ctermfg=255 
hi Comment    ctermfg=60
hi Constant   ctermfg=255
hi Identifier ctermfg=255
hi Statement  ctermfg=255
hi Type       ctermfg=255
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
hi Operator       ctermfg=255
hi Keyword        ctermfg=177
hi Include        ctermfg=177
hi Define         ctermfg=177
hi Macro          ctermfg=68
hi Typedef        ctermfg=255
hi Delimiter      ctermfg=117
hi SpecialComment ctermfg=60

hi ColorColumn  ctermbg=242
hi LineNr       ctermfg=243
hi LineNrAbove  ctermfg=243
hi LineNrBelow  ctermfg=243
hi CursorLineNr ctermfg=255

hi Menu       ctermfg=255
hi WildMenu   ctermfg=255 ctermbg=236 cterm=none
hi Pmenu      ctermfg=255 ctermbg=233 
hi PmenuSel   ctermfg=255 ctermbg=240
hi PmenuSbar  ctermfg=255 ctermbg=241
hi PmenuThumb ctermfg=255 ctermbg=236
hi CursorLine ctermbg=234 cterm=none
hi VertSplit  ctermfg=0   ctermbg=0
" hi Title      ctermfg=0   ctermbg=0

hi Folded     ctermfg=248 ctermbg=none cterm=bold
hi FoldColumn ctermfg=248 ctermbg=none cterm=bold
hi SignColumn ctermbg=none

hi rustStorage       ctermfg=177
hi rustLifetime      ctermfg=255
hi rustSigil         ctermfg=117
hi rustFoldBraces    ctermfg=117
hi rustModPath       ctermfg=255
hi rustModPathSep    ctermfg=255
hi rustDerive        ctermfg=255
hi rustAttribute     ctermfg=255
hi rustUnsafeKeyword ctermfg=177
hi rustSelf			 ctermfg=213

hi CocWarningSign  ctermfg=217
hi CocHintSign		  ctermfg=87
hi CocHighlightText ctermbg=235
