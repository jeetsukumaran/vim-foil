" vim-foil
"
" Foldable Outline Indented List
"
" By Jeet Sukumaran
" (C) Copyright 2021 Jeet Sukumaran
" Released under the same terms as Vim.
"
" Reload Guard {{{1
" ============================================================================
if exists("g:did_foil_plugin") && g:did_foil_plugin == 1
    finish
endif
let g:did_foil_plugin = 1
" }}} 1

" Compatibility Guard {{{1
" ============================================================================
" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" }}}1

" Globals {{{1
" ============================================================================
let g:foil_max_outline_level_color = get(g:, "foil_max_outline_level_color", 6)
let g:foil_shiftwidth = get(g:, "g:foil_shiftwidth", shiftwidth())
let g:foil_setup_highlights = get(g:, "g:sfoil_setup_highlights", 1)
let g:foil_heading_highlights = get(g:, "g:foil_heading_highlights", {})
let g:foil_outline_highlights = get(g:, "g:foil_outline_highlights", {})
" }}}1

" Folding Functions {{{1
" ============================================================================

" 0                     the line is not in a fold
" 1, 2, ..              the line is in a fold with this level
" "<1", "<2", ..        a fold with this level ends at this line
" ">1", ">2", ..        a fold with this level starts at this line
function! FoilFoldExpr()
    return foil#calc_fold_level(v:lnum)
endfunction

function! FoilFoldText()
    " return "[" . b:foil_line_fold_levels[v:foldstart] . "] " . getline(v:foldstart)
    return getline(v:foldstart)
endfunction

" }}}1

" Define Commands {{{1
" ============================================================================
command! FoilActivate :call foil#apply_to_buffer()
command! FoilDeactivate :call foil#deapply_buffer()
" }}}

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" }}}1

