augroup filetypedetect
  " Git
  autocmd Filetype gitcommit setlocal spell tw=72 colorcolumn=73
  " Go
  au FileType go setlocal noexpandtab
  " Rust
  au FileType rust setlocal expandtab
augroup END
