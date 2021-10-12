augroup foilfiletypedetect
    autocmd!
    autocmd BufNew,BufNewFile,BufRead *.outline.txt :set filetype=foil
   " autocmd BufNew,BufNewFile,BufRead *.outline :FoilActivate
augroup END
