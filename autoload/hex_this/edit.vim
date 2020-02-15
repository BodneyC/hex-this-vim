let s:hex_chars = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      \ 'a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F' ]
let s:func_opts = [ 'any', 'pick_fmt', 'hex', 'dec', 'ascii' ]

" TODO: Handle symbols

function! s:clear_cmd_line()
  redraw
  echo ''
endfunction

function! s:byte_under_cursor()
  let l:ho = b:byte_inf.hex_off
  return getline('.')[l:ho - 1:l:ho]
endfunction

"""""""" Converters

function! hex_this#edit#hex2ascii(str)
  return nr2char(str2nr(a:str, 16))
endfunction

function! hex_this#edit#ascii2hex(hex)
  return printf("%02x", char2nr(a:hex))
endfunction

function! hex_this#edit#dec2hex(dec)
  return printf("%02x", a:dec)
endfunction

"""""""" User input

function! hex_this#edit#input_hex()
  let l:cur_byte = <SID>byte_under_cursor()
  let l:msg = '(' . l:cur_byte . ') Input hex'
  let l:ret = ''
  for l:i in [0, 1]
    echo l:msg . ': ' . l:ret
    let l:ch = nr2char(getchar())
    while index(s:hex_chars, l:ch) == -1
      echo l:msg . ' ["' . l:ch . '" NaX]: ' . l:ret
      let l:ch = nr2char(getchar())
    endwhile
    let l:ret .= l:ch
  endfor
  return l:ret
endfunction

function! hex_this#edit#input_ascii()
  let l:cur_byte = hex_this#edit#hex2ascii(<SID>byte_under_cursor())
  echo '(' . l:cur_byte . ') Input ASCII char: '
  return hex_this#edit#ascii2hex(getchar())
endfunction

function! hex_this#edit#input_dec()
  let l:cur_byte = char2nr(hex_this#edit#hex2ascii(<SID>byte_under_cursor()))
  let l:msg = '(' . l:cur_byte . ') Input decimal'
  let l:inp = input(l:msg . ': ')
  while v:true
    let l:msge = ''
    if l:inp !~# '^\d\+$'
      let l:msge = 'NaN'
    elseif l:inp < 0
      let l:msge = '↓'
    elseif l:inp > 255
      let l:msge = '↑'
    endif
    if l:msge == '' | break | endif
    let l:inp = input(l:msg . ' ["' . l:inp . '" ' . l:msge . ']: ')
  endwhile
  return hex_this#edit#dec2hex(l:inp)
endfunction

function! hex_this#edit#input_any()
  let l:cur_byte = <SID>byte_under_cursor()
  let l:msg = '(' . l:cur_byte . ') Input: '
  let l:inp = input(l:msg)
  if len(l:inp) == 1
    return hex_this#edit#ascii2hex(l:inp)
  elseif len(l:inp) == 2 
        \ && index(s:hex_chars, l:inp[0]) != -1
        \ && index(s:hex_chars, l:inp[1]) != -1
    return l:inp
  elseif l:inp =~# '^\d\+$'
    return hex_this#edit#dec2hex(l:inp)
  endif
  return l:inp
  " throw '[VHT] Input "' . l:inp . '" not hex, ascii, or decimal'
endfunction

function! hex_this#edit#input_pick_fmt()
  let l:Finput = function('hex_this#edit#input_' 
        \ . s:func_opts[
        \     inputlist(
        \       map(s:func_opts[2:], { i, e ->
        \         (i + 1) . '. ' . substitute(e, '.*', '\u&', '')
        \       })
        \     ) + 1]
        \   )
  call <SID>clear_cmd_line()
  return l:Finput()
endfunction

"""""""" Editing

function! hex_this#edit#change_one(...) abort
  call hex_this#move#align_hl_groups()
  if ! exists('b:byte_inf')
    echo '[VHT] No byte selected'
    return
  endif

  let l:inp_fmt = get(a:, '1', 'any')

  if index(s:func_opts, l:inp_fmt) == -1
    throw '[VHT] Called input_<fmt> with arg not (dec|hex|ascii)'
  endif

  let l:Finput = function('hex_this#edit#input_' . l:inp_fmt)
  let l:inp = l:Finput()
  call <SID>clear_cmd_line()

  let l:pos = getpos('.')
  echo l:pos
  let l:sob = copy(l:pos)

  let l:sob[2] = b:byte_inf.hex_off
  call hex_this#move#curmove(l:sob)
  exec 'normal! R' . l:inp

  let l:sob[2] = b:byte_inf.ascii_off
  call setpos('.', l:sob)
  let l:ascii = hex_this#edit#hex2ascii(l:inp)
  if len(l:ascii) > 1
    let l:ascii = '.'
  endif
  exec 'normal! r' . l:ascii
  
  call hex_this#move#curmove(l:pos)
endfunction

function! hex_this#edit#change_many(inp_fmt) abort
  call hex_this#move#align_hl_groups()
  while v:true
    echom join(getpos('.'), ' ')
    call hex_this#edit#change_one()
    normal ll
    call <SID>clear_cmd_line()
  endwhile
endfunction

function! hex_this#edit#move_and_change(n, seq, inp_fmt) abort
  exec 'normal ' . a:seq
  if n < 2
    call hex_this#edit#change_one(a:inp_fmt)
  else
    call hex_this#edit#change_many(a:inp_fmt)
  endif
endfunction

" vim: et ts=2 sw=2 tw=110
