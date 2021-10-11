" Vim syntax file
" Language: Hierarchical Indented List Outline
" Maintainer: Jeet Sukumaran
" Latest Revision: 2021-09-25

" if exists("b:current_syntax")
"   finish
" endif

syntax clear
" syntax region outlineHeader1 start=/^\s*[#=] .*/ end=/$/
" syntax region outlineHeader2 start=/^\s*\(#\{2}\|=\{2}\) .*/ end=/$/
" syntax region outlineHeader3 start=/^\s*\(#\{3}\|=\{3}\) .*/ end=/$/
" syntax region outlineLevel1     start=/^\([-*]\|[0-9]\+[.)]\)/ end=/$/ contains=outlineLevel1Leader oneline
" syntax region outlineLevel1Leader start=/^\([-*]\|[0-9]\+[.)]\)/ end=/\s\+/ contained
" syntax region outlineLevel2  start=/\%5c\([-*]\|[0-9]\+[.)]\)/ end=/$/ oneline
" syntax region outlineLevel3  start=/\%9c\([-*]\|[0-9]\+[.)]\)/ end=/$/ oneline
" syntax region outlineLevel4 start=/\%13c\([-*]\|[0-9]\+[.)]\)/ end=/$/ oneline
" syntax region outlineLevel5 start=/\%17c\([-*]\|[0-9]\+[.)]\)/ end=/$/ oneline
" syntax region outlineLevel6 start=/\%21c\([-*]\|[0-9]\+[.)]\)/ end=/$/ oneline

if &background == "dark"
    hi! outlineHeader1 guifg=#904040 gui=italic,underline,bold
    hi! outlineHeader2 guifg=#807070 gui=italic,undercurl,bold
    if g:foil_max_outline_level_color >= 1
        hi! outlineLevel1 guifg=#977070 gui=bold
    endif
    if g:foil_max_outline_level_color >= 2
        hi! outlineLevel2 guifg=#448888 gui=bold
    endif
    if g:foil_max_outline_level_color >= 3
        hi! outlineLevel3 guifg=#5b8060 gui=bold
    endif
    if g:foil_max_outline_level_color >= 4
        hi! outlineLevel4 guifg=#999988 gui=bold
    endif
    if g:foil_max_outline_level_color >= 5
        hi! outlineLevel5 guifg=#808060 gui=bold
    endif
    if g:foil_max_outline_level_color >= 6
        hi! outlineLevel6 guifg=#667070 gui=bold
    endif
else
endif

let b:current_syntax = "foil"


