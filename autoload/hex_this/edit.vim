let s:hex_chars = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      \ 'a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F' ]
let s:func_opts = [ 'any', 'pick_fmt', 'hex', 'dec', 'ascii' ]

" TODO: Handle symbols

function! s:clear_cmd_line()
  redraw
  echo ''
endfunction

function! s:byte_under_cursor()
  let ho = b:byte_inf.hex_off
  return getline('.')[ho - 1:ho]
endfunction

"""""""" Converters

function! hex_this#edit#hex2ascii(str)
  let nr = str2nr(a:str, 16)
  if nr < 33 || (nr > 126 && nr < 161)
    let nr = 46 " Period
  endif
  return nr2char(nr)
endfunction

function! hex_this#edit#ascii2hex(hex)
  return printf("%02x", char2nr(a:hex))
endfunction

function! hex_this#edit#dec2hex(dec)
  return printf("%02x", a:dec)
endfunction

"""""""" User input

function! hex_this#edit#input_hex()
  let cur_byte = <SID>byte_under_cursor()
  let msg = '(' . cur_byte . ') Input hex'
  let ret = ''
  for i in [0, 1]
    echo msg . ': ' . ret
    let ch = nr2char(getchar())
    while index(s:hex_chars, ch) == -1
      if char2nr(ch) < 30
        return
      endif
      echo msg . ' ["' . ch . '" NaX]: ' . ret
      let ch = nr2char(getchar())
    endwhile
    let ret .= ch
  endfor
  return ret
endfunction

function! hex_this#edit#input_ascii()
  let cur_byte = hex_this#edit#hex2ascii(<SID>byte_under_cursor())
  echo '(' . cur_byte . ') Input ASCII char: '
  return hex_this#edit#ascii2hex(nr2char(getchar()))
endfunction

function! hex_this#edit#input_dec()
  let cur_byte = char2nr(hex_this#edit#hex2ascii(<SID>byte_under_cursor()))
  let msg = '(' . cur_byte . ') Input decimal'
  let inp = input(msg . ': ')
  while v:true
    let msge = ''
    if inp !~# '^\d\+$'
      let msge = 'NaN'
    elseif inp < 0
      let msge = '↓'
    elseif inp > 255
      let msge = '↑'
    endif
    if msge == '' | break | endif
    let inp = input(msg . ' ["' . inp . '" ' . msge . ']: ')
  endwhile
  return hex_this#edit#dec2hex(inp)
endfunction

function! hex_this#edit#input_any()
  let cur_byte = <SID>byte_under_cursor()
  let msg = '(' . cur_byte . ') Input: '
  let inp = input(msg)
  if len(inp) == 0
    return
  endif

  if len(inp) == 1
    return hex_this#edit#ascii2hex(inp)
  endif

  if len(inp) == 2 
        \ && index(s:hex_chars, inp[0]) != -1
        \ && index(s:hex_chars, inp[1]) != -1
    return inp
  endif

  if inp =~# '^\d\+$'
    return hex_this#edit#dec2hex(inp)
  endif

  echo '[HT] Input "' . inp . '" not hex, ascii, or decimal'
endfunction

function! hex_this#edit#input_pick_fmt()
  let opt = inputlist(
        \   map(s:func_opts[2:], { i, e ->
        \     (i + 1) . '. ' . substitute(e, '.*', '\u&', '')
        \   })
        \ )
  if ! opt | return | endif
  let Finput = function('hex_this#edit#input_' . s:func_opts[opt + 1])
  call <SID>clear_cmd_line()
  return Finput()
endfunction

"""""""" Editing

function! hex_this#edit#change_one(...) abort
  call hex_this#move#align_hl_groups()

  if ! exists('b:byte_inf')
    echo '[HT] No byte selected'
    return
  endif

  let inp_fmt = get(a:, '1', 'any')

  if index(s:func_opts, inp_fmt) == -1
    throw '[HT] Called input_<fmt> with arg not (dec|hex|ascii)'
  endif

  let Finput = function('hex_this#edit#input_' . inp_fmt)
  let inp = Finput()
  call <SID>clear_cmd_line()

  if ! inp | return | endif

  let pos = getpos('.')
  let sob = copy(pos)

  let sob[2] = b:byte_inf.hex_off
  call hex_this#move#curmove(sob)
  exec 'normal! R' . inp

  let sob[2] = b:byte_inf.ascii_off
  call setpos('.', sob)
  let ascii = hex_this#edit#hex2ascii(inp)
  if len(ascii) > 1
    let ascii = '.'
  endif
  exec 'normal! r' . ascii
  
  call hex_this#move#curmove(pos)

  return inp
endfunction

function! hex_this#edit#change_many(inp_fmt) abort
  call hex_this#move#align_hl_groups()
  while v:true
    if ! hex_this#edit#change_one()
      break
    endif
    normal ll
    call <SID>clear_cmd_line()
  endwhile
endfunction

function! hex_this#edit#move_and_change(n, inp_fmt, seq) abort
  exec 'normal ' . a:seq
  if a:n < 2
    call hex_this#edit#change_one(a:inp_fmt)
  else
    call hex_this#edit#change_many(a:inp_fmt)
  endif
endfunction

function! hex_this#edit#func_and_change(n, inp_fmt, func, ...) abort
  let args = ''
  if exists('a:000')
    let args = join(a:000, ', ')
  endif
  exec 'call ' . a:func . '(' . args . ')' |
  if a:n < 2
    call hex_this#edit#change_one(a:inp_fmt)
  else
    call hex_this#edit#change_many(a:inp_fmt)
  endif
endfunction

" vim: et ts=2 sw=2 tw=110
