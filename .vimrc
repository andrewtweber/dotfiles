" Use UTF-8 without BOM
set encoding=utf-8 nobomb

" Syntax highlighting
syntax on

" 4 spaces per tab, convert tabs to spaces
set tabstop=4 shiftwidth=4 expandtab

" allow moving cursor to true end of line
set virtualedit=onemore

" Show cursor position
set ruler

" Hide line numbers
set nonumber

" Highlight search results
set hlsearch

" Start scrolling 3 lines before window edge
set scrolloff=3

" Clear search highlighting when you hit enter
nnoremap <CR> :nohlsearch<CR><CR>:<backspace>

if has("autocmd")
    " Enable file type detection
    filetype on

    " Highlight .json files as .js
    autocmd BufNewFile,BufRead *.json,*.vue setfiletype json syntax=javascript

    " Highlight .md files as Markdown
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown

    " Don't convert tabs to spaces in html, blade, and js files
    autocmd BufRead,BufNewFile *.html,*.blade.php,*.js,*.vue set noexpandtab

    " Highlight .env.example files as shell
    autocmd BufNewFile,BufRead *.env.example setlocal filetype=sh

    " Remember last open position
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
