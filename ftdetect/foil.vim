augroup filetypedetect
    autocmd BufNew,BufNewFile,BufRead *.outline,*.outline.txt :set filetype=foil
    autocmd BufNew,BufNewFile,BufRead *.outline,*.outline.txt :FoilActivate
augroup END
