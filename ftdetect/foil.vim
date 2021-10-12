" augaqroup foilfiletypedetect
"     autocmd!
"     " weird Neovim bug: this works alright on first read (e.g., does not do
"     " anything to files with the filetype is not matched. But when hitting <C-O>
"     " in an unmatched filetype (e.g., "other.txt" or ".zzz") and the cursor
"     " jumps to a location in the same file, causes the filetype of the file
"     " change. That is, opening an "foo.zzz" file will be fine, but if you hit
"     " <C-o> anywhere in it, whether or not the jump dest is within or in
"     " another buffer, then this ftdetect will be called and the file type will
"     " be set it "foil".
"     autocmd BufNew,BufNewFile,BufRead *.outline.txt :set filetype=foil
"    " autocmd BufNew,BufNewFile,BufRead *.outline :FoilActivate
" augroup END
