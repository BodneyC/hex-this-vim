let g:hex_this_cache_dir = get(g:, 'hex_this_cache_dir', expand('$HOME/.cache/vim/hex-this'))
let g:hex_this_xxd_path = get(g:, 'hex_this_xxd_path', '')
let g:hex_this_base64_path = get(g:, 'hex_this_base64_path', '')

let g:hex_this_cols = get(g:, 'hex_this_cols', 16)
let g:hex_this_byte_space = get(g:, 'hex_this_byte_space', 2)
let g:hex_this_upper = get(g:, 'hex_this_upper', v:false)

let g:hex_this_n_lines = get(g:, 'hex_this_n_lines', 16)
let g:hex_this_n_bytes = get(g:, 'hex_this_n_bytes', g:hex_this_byte_space)

let g:hex_this_augroup = get(g:, 'hex_this_augroup', 1)

hi! clear HexThisAsciiEq
hi HexThisAsciiEq ctermbg=darkred ctermfg=white guibg='#882342' guifg='#ffffff'
hi HexThisHexEq ctermbg=blue ctermfg=white guibg='#2233ee' guifg='#ffffff'

if g:hex_this_augroup
  augroup __HEX_THIS__
    au!
    au BufEnter *.xxd set ft=xxd
    au FileType xxd call hex_this#continue()
  augroup END
endif

command! -nargs=* HexThis     call hex_this#init(<f-args>)
command! -nargs=0 HexContinue call hex_this#continue()
command! -nargs=* HexReset    call hex_this#reset(<f-args>)
command! -nargs=* HexWrite    call hex_this#write(<f-args>)
command! -nargs=? HexAddLines call hex_this#add_lines(<f-args>)
command! -nargs=? HexAddBytes call hex_this#add_bytes(<f-args>)

" vim: et ts=2 sw=2 tw=110
