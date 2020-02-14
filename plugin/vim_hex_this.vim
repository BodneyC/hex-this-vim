let g:hex_this_cache_dir = get(g:, 'hex_this_cache_dir', expand('$HOME/.cache/vim/hex-this'))
let g:hex_this_xxd_path = get(g:, 'hex_this_xxd_path', '')
let g:hex_this_base64_path = get(g:, 'hex_this_base64_path', '')

let g:hex_this_cols = get(g:, 'hex_this_cols', 16)
let g:hex_this_byte_space = get(g:, 'hex_this_byte_space', 2)
let g:hex_this_upper = get(g:, 'hex_this_upper', v:false)

hi! clear HexThisAsciiEq
hi HexThisAsciiEq ctermbg=darkred ctermfg=black guibg='#771231' guifg='#ffffff'

command! -nargs=* HexThis call vim_hex_this#init(<f-args>)
command! -nargs=0 HexWrite call vim_hex_this#write()

" vim: et ts=2 sw=2 tw=110
