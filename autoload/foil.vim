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

" Housekeeping Functions {{{1
" ============================================================================

function! foil#init()
    let g:foil_initialized = 1
    let s:header_level_patterns = {}
    let s:header_level_patterns['^\s*[#=] .*'] =  1
    let s:header_level_patterns['^\s*\(#\{2}\|=\{2}\) .*'] =  1
    let s:header_level_patterns['^\s*\(#\{3}\|=\{3}\) .*'] =  1
    let s:header_level_patterns['^\([-*]\|[0-9]\+[.)]\)'] =  1
    let s:header_level_patterns['\%5c\([-*]\|[0-9]\+[.)]\)'] =  2
    let s:header_level_patterns['\%9c\([-*]\|[0-9]\+[.)]\)'] =  3
    let s:header_level_patterns['\%13c\([-*]\|[0-9]\+[.)]\)'] =  4
    let s:header_level_patterns['\%17c\([-*]\|[0-9]\+[.)]\)'] =  5
    let s:header_level_patterns['\%21c\([-*]\|[0-9]\+[.)]\)'] =  6
    return s:header_level_patterns
endfunction!

" function! foil#check_buffer()
"     if g:foil_auto_enable
"         let fname = expand("%")
"         for excp in g:foil_exclude_file_patterns
"             if match(fname, excp) >= 0
"                 return
"             endif
"         endfor
"         for bft in keys(g:foil_filetypes)
"             if &ft == bft
"                 call foil#apply_to_buffer()
"             endif
"         endfor
"     endif
" endfunction

function! foil#apply_to_buffer()
    if exists("b:foil_applied_to_buffer")
        return
    endif
    let b:foil_buffer_foldmethod = &foldmethod
    let b:foil_buffer_foldexpr = &foldexpr
    let b:foil_buffer_foldtext = &foldtext
    setlocal foldmethod=expr
    if !exists("b:foil_buffer_autocommands")
        augroup FoilFastFolding
            autocmd InsertEnter <buffer> call foil#save_and_restore_foldmethod("insert-enter")
            autocmd InsertLeave <buffer> call foil#save_and_restore_foldmethod("insert-leave")
        augroup end
        let b:foil_buffer_autocommands = 1
    endif
    setlocal foldexpr=FoilFoldExpr()
    setlocal foldtext=FoilFoldText()
    let b:foil_line_fold_levels = {}
    let b:foil_applied_to_buffer = 1
endfunction!

function! foil#deapply_buffer()
    if !exists("g:foil_initialized")
        call foil#init()
    endif
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

function! foil#save_and_restore_foldmethod(mode)
    if a:mode == "insert-enter"
        let b:foil_foldmethod_on_insert_enter = &foldmethod
        setlocal foldmethod=manual
    elseif a:mode == "insert-leave"
        let fm = get(b:, "foil_foldmethod_on_insert_enter", "expr")
        execute "setlocal foldmethod=" . fm
    end
endfunction

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

function! foil#get_text_fold_start_level(text)
    if !exists("s:header_level_patterns")
        call foil#init()
    endif
    for pattern in keys(s:header_level_patterns)
        echomsg s:header_level_patterns[pattern]
        if a:text =~ pattern
        " if match(pattern, a:text) >= 0
            return s:header_level_patterns[pattern]
        endif
    endfor
    return -1
endfunction

" function! foil#ToggleHighlight(group_name, ...)
"     if a:0 == 0
"         let level = 1
"     else
"         let level = a:1
"     endif
"     call foil#toggle_hlattribute(a:group_name . level, "gui", "reverse")
" endfunction

" }}}1

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" }}}1
