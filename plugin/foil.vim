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
let g:did_foil_plugin = 1
" }}} 1

" Compatibility Guard {{{1
" ============================================================================
" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" }}}1

" Housekeeping Functions {{{1
" ============================================================================

" function! s:_foil_init()
"     let g:foil_filetypes = {}
"     let g:foil_native_filetypes = {
"                 \ "tex": "s:_foil_tex",
"                 \ "latex": "s:_foil_tex",
"                 \ "rst": "s:_foil_restructured_text",
"                 \ "rest": "s:_foil_restructured_text",
"                 \ "md": "s:_foil_markdown",
"                 \ "markdown": "s:_foil_markdown",
"                 \ "mkd": "s:_foil_markdown",
"                 \ "pandoc": "s:_foil_pandoc"
"                 \ }
"     for key in keys(g:foil_native_filetypes)
"         let g:foil_filetypes[key] = g:foil_native_filetypes[key]
"     endfor
"     for key in keys(g:foil_user_filetypes)
"         let g:foil_filetypes[key] = g:foil_user_filetypes[key]
"     endfor
" endfunction!

" function! s:_foil_check_buffer()
"     if g:foil_auto_enable
"         let fname = expand("%")
"         for excp in g:foil_exclude_file_patterns
"             if match(fname, excp) >= 0
"                 return
"             endif
"         endfor
"         for bft in keys(g:foil_filetypes)
"             if &ft == bft
"                 call s:_foil_apply_to_buffer()
"             endif
"         endfor
"     endif
" endfunction

function! s:_foil_apply_to_buffer()
    " if exists("b:foil_applied_to_buffer")
    "     return
    " endif
    let b:foil_buffer_foldmethod = &foldmethod
    let b:foil_buffer_foldexpr = &foldexpr
    let b:foil_buffer_foldtext = &foldtext
    setlocal foldmethod=expr
    if !exists("b:foil_buffer_autocommands")
        augroup FoilFastFolding
            autocmd InsertEnter <buffer> call s:_foil_save_and_restore_foldmethod("insert-enter")
            autocmd InsertLeave <buffer> call s:_foil_save_and_restore_foldmethod("insert-leave")
        augroup end
        let b:foil_buffer_autocommands = 1
    endif
    setlocal foldexpr=FoilFoldExpr()
    setlocal foldtext=FoilFoldText()
    let b:foil_line_fold_levels = {}
    let b:foil_applied_to_buffer = 1
endfunction!

function! s:_foil_deapply_buffer()
    execute "setlocal foldmethod=" . get(b:, "foil_buffer_foldmethod", &foldmethod)
    execute "setlocal foldexpr=" . get(b:, "foil_buffer_foldexpr", &foldexpr)
    execute "setlocal foldtext=" . get(b:, "foil_buffer_foldtext", &foldtext)
    augroup FoilFastFolding
        autocmd!
    augroup end
    if exists("b:foil_buffer_foldmethod")
        unlet b:foil_buffer_foldmethod
    endif
    if exists("b:foil_buffer_foldexpr")
        unlet b:foil_buffer_foldexpr
    endif
    if exists("b:foil_buffer_foldtext")
        unlet b:foil_buffer_foldtext
    endif
    if exists("b:foil_buffer_autocommands")
        unlet b:foil_buffer_autocommands
    endif
    if exists("b:foil_previous_line_foldlevel")
        unlet b:foil_previous_line_foldlevel
    endif
    if exists("b:foil_applied_to_buffer")
        unlet b:foil_applied_to_buffer
    endif
endfunction!

function! s:_foil_save_and_restore_foldmethod(mode)
    if a:mode == "insert-enter"
        let b:foil_foldmethod_on_insert_enter = &foldmethod
        setlocal foldmethod=manual
    elseif a:mode == "insert-leave"
        let fm = get(b:, "foil_foldmethod_on_insert_enter", "expr")
        execute "setlocal foldmethod=" . fm
    end
endfunction

" }}}1

" Folding Functions {{{1
" ============================================================================

function! s:_foil_get_text_fold_start_level(text)
    if a:text =~ '^\s*[#=] .*'
        return 1
    elseif a:text =~ '^\s*\(#\{2}\|=\{2}\) .*'
        return 1
    elseif a:text =~ '^\s*\(#\{3}\|=\{3}\) .*'
        return 1
    elseif a:text =~ '^\([-*]\|[0-9]\+[.)]\)'
        return 1
    elseif a:text =~ '\%5c\([-*]\|[0-9]\+[.)]\)'
        return 3
    elseif a:text =~ '\%9c\([-*]\|[0-9]\+[.)]\)'
        return 4
    elseif a:text =~ '\%13c\([-*]\|[0-9]\+[.)]\)'
        return 5
    elseif a:text =~ '\%17c\([-*]\|[0-9]\+[.)]\)'
        return 6
    elseif a:text =~ '\%21c\([-*]\|[0-9]\+[.)]\)'
        return 7
    endif
    return -1
endfunction

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
    let fold_start_level = s:_foil_get_text_fold_start_level(vline)
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
    return getline(v:foldstart)
endfunction

" }}}1

" Define Commands {{{1
" ============================================================================
" command! FoilInit :call <SID>_foil_init()
command! FoilActivate :call <SID>_foil_apply_to_buffer()
command! FoilDeactivate :call <SID>_foil_deapply_buffer()
" }}}

:FoilActivate

" set foldexpr=FoilFoldExpr()
" set foldtext=FoilFoldText()
" set foldmethod=expr

" Globals {{{1
" ============================================================================
let g:foil_max_outline_level_color = get(g:, "foil_max_outline_level_color", 6)
" }}}1

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" }}}1

