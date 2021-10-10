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
" if exists("g:did_foil_plugin") && g:did_foil_plugin == 1
"     finish
" endif
" let g:did_foil_plugin = 1
" }}} 1

" Compatibility Guard {{{1
" ============================================================================
" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" }}}1

" Support {{{1
" ============================================================================
function! foil#toggle_hlattribute(hlname, hlelem, hlattr)
    " Redirect output of :highlight to l:current
    redir => l:current_hl
        execute 'silent highlight ' . a:hlname
    redir END
    let current_elem = matchstr(current_hl, '.*' . a:hlattr . '=\zs\S\+\ze')
    let current_elem = matchstr(current_hl, '.*' . a:hlelem . '=\zs\S\+\ze')
    let current_elem_parts = split(current_elem, ",")
    let new_elem_parts = []
    let attr_found = 0
    for attr in current_elem_parts
        if attr == a:hlattr
            let attr_found = 1
        else
            call add(new_elem_parts, attr)
        endif
    endfor
    if !attr_found
        call add(new_elem_parts, a:hlattr)
    endif
    if len(new_elem_parts) == 0
        call add(new_elem_parts, "none")
    endif
    let cmd = "highlight " . a:hlname . " " . a:hlelem . "=" . join(new_elem_parts, ",")
    execute cmd
endfunction

function! foil#ToggleHighlight(group_name, ...)
    if a:0 == 0
        let level = 1
    else
        let level = a:1
    endif
    call foil#toggle_hlattribute(a:group_name . level, "gui", "reverse")
endfunction
" }}}1

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" }}}1
