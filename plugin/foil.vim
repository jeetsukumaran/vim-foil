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

" Folding Functions {{{1
" ============================================================================

" 0                     the line is not in a fold
" 1, 2, ..              the line is in a fold with this level
" "<1", "<2", ..        a fold with this level ends at this line
" ">1", ">2", ..        a fold with this level starts at this line
function! FoilFoldExpr()
    " if b:foil_line_fold_levels[v:lnum+1] != "-1"
    "     " previously calculated level for this line
    "     return b:foil_line_fold_levels[v:lnum+1]
    " end
    let vline = getline(v:lnum)
    let fold_start_level = foil#get_text_fold_start_level(vline)
    if fold_start_level == -1
        let indentlevel = indent(v:lnum) / shiftwidth()
        if indentlevel == 0
            let fold_level = b:foil_line_fold_levels[v:lnum-1]
        else
            let fold_level = indentlevel + 1
        end
        let b:foil_line_fold_levels[v:lnum] = fold_level
        let fold_expr_val = fold_start_level
    else
        let b:foil_line_fold_levels[v:lnum] = fold_start_level
        let fold_expr_val = ">" . fold_start_level
    endif
    return fold_expr_val
endfunction

function! FoilFoldText()
    return "[" . b:foil_line_fold_levels[v:foldstart] . "] " . getline(v:foldstart)
    " return getline(v:foldstart)
endfunction

" }}}1

" Define Commands {{{1
" ============================================================================
" command! FoilInit :call foil#init()
command! FoilActivate :call foil#apply_to_buffer()
command! FoilDeactivate :call foil#deapply_buffer()
" }}}

" Globals {{{1
" ============================================================================
let g:foil_max_outline_level_color = get(g:, "foil_max_outline_level_color", 6)
" }}}1

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" }}}1

