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
    " keys = regexp patterns
    " value = [a, b], where:
    "   -   a = fold level
    "   -   b = heading level (for syntax coloration)
    let s:heading_fold_level_patterns = {}
    let s:heading_fold_level_patterns['^\s*[#=] .*'] =  [1, 1]
    let s:heading_fold_level_patterns['^\s*\(#\{2}\|=\{2}\) .*'] =  [1, 2]
    let s:heading_fold_level_patterns['^\s*\(#\{3}\|=\{3}\) .*'] =  [2, 3]
    let s:heading_fold_level_patterns['^\s*\(#\{4}\|=\{4}\) .*'] =  [3, 4]
    let s:heading_fold_level_patterns['^\s*\(#\{5}\|=\{5}\) .*'] =  [4, 5]
    let s:heading_fold_level_patterns['^\s*\(#\{6}\|=\{6}\) .*'] =  [5, 6]
    let s:heading_fold_level_patterns['^\s*\(#\{7}\|=\{7}\) .*'] =  [6, 7]
    let s:outline_fold_level_patterns = {}
    " let s:outline_fold_level_patterns['^\([-*]\|[0-9]\+[.)]\)'] =  1
    " let s:outline_fold_level_patterns['\%5c\([-*]\|[0-9]\+[.)]\)'] =  2
    " let s:outline_fold_level_patterns['\%9c\([-*]\|[0-9]\+[.)]\)'] =  3
    " let s:outline_fold_level_patterns['\%13c\([-*]\|[0-9]\+[.)]\)'] =  4
    " let s:outline_fold_level_patterns['\%17c\([-*]\|[0-9]\+[.)]\)'] =  5
    " let s:outline_fold_level_patterns['\%21c\([-*]\|[0-9]\+[.)]\)'] =  6
    " let s:outline_fold_level_patterns['\%25c\([-*]\|[0-9]\+[.)]\)'] =  7
    for level in range(0, 10)
        let leader = repeat(" ", level * g:foil_shiftwidth)
        let pattern = "^" .. leader .. "- .*"
        let s:outline_fold_level_patterns[pattern] = [level + 1, level + 1]
    endfor

    " highly oxygenated blood red      = "#9d0006",
    " green    = "#79740e",
    " orange   = "#b57614",
    " blue     = "#076678",
    " purple   = "#8f3f71",
    " aqua     = "#427b58",
    " faded red   = "#af3a03",

    let s:default_heading_highlights = {
                \   1: "guifg=#af3a03 gui=italic,underline,bold",
                \   2: "guifg=#b57614 gui=italic,undercurl,bold",
                \   3: "guifg=#79740e gui=italic,underline,bold",
                \   4: "guifg=#8f3f71 gui=italic,undercurl,bold",
                \   5: "guifg=#807070 gui=italic,undercurl,bold",
                \}
    " 1: "guifg=#928374 gui=bold",
    let s:default_outline_highlights = {
                \    1: "guifg=#977070 gui=bold",
                \    2: "guifg=#448888 gui=bold",
                \    3: "guifg=#5b8060 gui=bold",
                \    4: "guifg=#999988 gui=bold",
                \    5: "guifg=#808060 gui=bold",
                \    6: "guifg=#667070 gui=bold",
                \}
    let g:foil_initialized = 1
    return s:outline_fold_level_patterns
endfunction!

function! foil#setup_syntax()
    if !exists("g:foil_initialized")
        call foil#init()
    endif
    call foil#setup_heading_and_levels_syntax()
    call foil#setup_special_syntax()
endfunction

function! foil#setup_heading_and_levels_syntax()
    for pattern in keys(s:heading_fold_level_patterns)
        let heading_level = s:heading_fold_level_patterns[pattern][1]
        let syntax_name = "outlineHeader" . heading_level
        execute "syntax region " . syntax_name . " start=/" . pattern . "/ end=/$/"
        let highlight_def = get(g:foil_heading_highlights,
                    \   heading_level,
                    \   get(s:default_heading_highlights, heading_level, "")
                    \)
        if g:foil_setup_highlights && highlight_def != ""
            execute "highlight! " . syntax_name . " " . highlight_def
        endif
    endfor
    for pattern in keys(s:outline_fold_level_patterns)
        let outline_level = s:outline_fold_level_patterns[pattern][1]
        let syntax_name = "outlineLevel" . outline_level
        execute "syntax region " . syntax_name . " start=/" . pattern . "/ end=/$/"
        let highlight_def = get(g:foil_outline_highlights,
                    \   outline_level,
                    \   get(s:default_outline_highlights, outline_level, "")
                    \)
        if g:foil_setup_highlights && highlight_def != ""
            execute "highlight! " . syntax_name . " " . highlight_def
        endif
    endfor
endfunction

function! foil#setup_special_syntax()

    " generic code
    syntax region outlineCodeSnippet matchgroup=SpecialComment start="```" end="```" keepend

    " specialized code
    for [ft, lang_tag] in [
                \   ["python", "python",],
                \   ["bash", "bash",],
                \]
        call foil#setup_code_snippet_syntax(ft, "```" . lang_tag, "```", "SpecialComment")
    endfor
    " call foil#setup_code_snippet_syntax("tex", "```tex", "```", "SpecialComment")

    highlight! link outlineTexMath SpecialComment
    highlight! link outlineTexMathBody Constant
    call foil#setup_latex_env_syntax("align", "outlineTexMath", "outlineTexMathBody")
    call foil#setup_latex_env_syntax("align\\*", "outlineTexMath", "outlineTexMathBody")
endfunction

function! foil#setup_latex_env_syntax(pattern, name, body_name)
    let sr = ""
    let sr .= "syntax region " . a:name
    let sr .= " start='\\\\begin{" . a:pattern . "}' end='\\\\end{" . a:pattern . "}'"
    let sr .= " contains=" . a:body_name
    execute sr

    let sr = ""
    let sr .= "syntax region " . a:body_name
    let sr .= " start='\\\\begin{" . a:pattern . "}\\zs' end='\\ze\\\\end{" . a:pattern . "}'"
    execute sr
endfunction

function! foil#setup_code_snippet_syntax(filetype, start, end, textSnipHl) abort
    let ft=toupper(a:filetype)
    let group='textGroup'.ft
    if exists('b:current_syntax')
        let s:current_syntax=b:current_syntax
        " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
        " do nothing if b:current_syntax is defined.
        unlet b:current_syntax
    endif
    execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
    try
        execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
    catch
    endtry
    if exists('s:current_syntax')
        let b:current_syntax=s:current_syntax
    else
        unlet b:current_syntax
    endif
    execute 'syntax region textSnip'.ft.'
                \ matchgroup='.a:textSnipHl.'
                \ keepend
                \ start="'.a:start.'" end="'.a:end.'"
                \ contains=@'.group
endfunction


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
    if !exists("g:foil_initialized")
        call foil#init()
    endif
    if exists("b:foil_applied_to_buffer")
        return
    endif
    " let b:foil_buffer_ft = &ft
    let b:foil_buffer_foldmethod = &foldmethod
    let b:foil_buffer_foldexpr = &foldexpr
    let b:foil_buffer_foldtext = &foldtext
    " setlocal ft=foil
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
    call foil#setup_syntax()
    let b:foil_line_fold_levels = {}
    let b:foil_applied_to_buffer = 1
endfunction!

function! foil#deapply_buffer()
    " execute "setlocal ft=" . get(b:, "foil_buffer_ft", &ft)
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

function! foil#recalc_all(buf_ref)
    let lnum = 1
    let last_line_nr = line("$")
    while lnum <= last_line_nr
        let fl = foil#calc_fold_level(lnum)
        let lnum = lnum + 1
    endwhile
endfunction

" }}}1

" Folding Support {{{1
" ============================================================================

function! foil#get_text_fold_start_level(text)
    if !exists("s:outline_fold_level_patterns")
        call foil#init()
    endif
    for pattern in keys(s:heading_fold_level_patterns)
        if a:text =~ pattern
            return s:heading_fold_level_patterns[pattern][0]
        endif
    endfor
    for pattern in keys(s:outline_fold_level_patterns)
        if a:text =~ pattern
        " if match(pattern, a:text) >= 0
            return s:outline_fold_level_patterns[pattern][0]
        endif
    endfor
    return -1
endfunction

function! foil#calc_fold_level(lnum)
    " if b:foil_line_fold_levels[a:lnum+1] != "-1"
    "     " previously calculated level for this line
    "     return b:foil_line_fold_levels[a:lnum+1]
    " end
    let vline = getline(a:lnum)
    " let vlines = getbufline(a:buf_ref, a:lnum)
    " if empty(vlines)
    "     return -1
    " endif
    let fold_start_level = foil#get_text_fold_start_level(vline)
    if fold_start_level == -1
        let indentlevel = indent(a:lnum) / g:foil_shiftwidth
        if indentlevel == 0
            let fold_level = b:foil_line_fold_levels[a:lnum-1][0]
        else
            let fold_level = indentlevel
        end
        let b:foil_line_fold_levels[a:lnum] = [fold_level, ""]
        let fold_expr_val = fold_level
    else
        let b:foil_line_fold_levels[a:lnum] = [fold_start_level, ">"]
        let fold_expr_val = ">" . fold_start_level
    endif
    return fold_expr_val
endfunction

" }}}1

" Editing Support {{{1
" ============================================================================

function! foil#get_outline_range(lnum)
    let start_ln = a:lnum
    call foil#calc_fold_level(a:lnum)
    let range_start = a:lnum
    let range_level =  b:foil_line_fold_levels[range_start][0]
    while range_start > 1
        if b:foil_line_fold_levels[range_start][1] == ">"
            break
        endif
        let range_start = range_start - 1
        call foil#calc_fold_level(range_start)
    endwhile
    let range_end = a:lnum + 1
    let last_line_nr = line("$")
    while range_end <= last_line_nr
        call foil#calc_fold_level(range_end)
        let calc = b:foil_line_fold_levels[range_end]
        " echomsg  range_end . ": " . calc[0] . ", " . calc[1] . " (" . range_level . ")"
        if (
                    \ (calc[0] < range_level)
                    \ || (calc[0] == range_level && calc[1] == ">")
                    \ )
            let range_end = range_end - 1
            break
        endif
        let range_end = range_end + 1
    endwhile
    " echomsg  range_start . " => " . range_end
    return [range_start, range_end, range_level]
endfunction

function! foil#shift_level(lnum, is_increase)
    let block_range = foil#get_outline_range(a:lnum)
    if a:is_increase
        let find_pattern = "^" . repeat(" ", g:foil_shiftwidth)
        let replace_pattern = ""
    else
        let find_pattern = "^"
        let replace_pattern = repeat(" ", g:foil_shiftwidth)
    endif
    for block_lnum in range(block_range[0], block_range[1])
        let text = getline(block_lnum)
        let rtext = substitute(text, find_pattern, replace_pattern, "")
        call setline(block_lnum, rtext)
    endfor
endfunction

function! foil#promote(lnum)
    call foil#shift_level(a:lnum, 1)
endfunction

function! foil#demote(lnum)
    call foil#shift_level(a:lnum, 0)
endfunction

" }}}1

" Miscellaneous {{{1
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

" function! foil#ToggleHighlight(group_name, ...)
"     if a:0 == 0
"         let level = 1
"     else
"         let level = a:1
"     endif
"     call foil#toggle_hlattribute(a:group_name . level, "gui", "reverse")
" endfunction

" }}}1

" Key Mapping {{{1
" ============================================================================

nnoremap <silent> <Plug>(FoilPromote) :call foil#promote(line("."))<CR>
nnoremap <silent> <Plug>(FoilDemote) :call foil#demote(line("."))<CR>

if !exists("g:foil_suppress_keymaps") || !g:foil_suppress_keymaps
    if !hasmapto('<Plug>(FoilPromote)')
        map \< <Plug>(FoilPromote)
    endif
    if !hasmapto('<Plug>(FoilDemote)')
        map \> <Plug>(FoilDemote)
    endif
endif
" }}}1

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" }}}1
