let s:hl = { 'h': -1, 'l': 1 }
let s:wb = { 'b': 'h', 'w': 'l' }
let s:jk = { 'j': 1, 'k': -1 }
let s:chunk = { 'W': 1, 'e': 1, 'E': 1,
      \ 'B': -1, 'ge': -1, 'gE': -1 }

""""""" Util functions

function! hex_this#move#align_hl_groups()
  let l:x = getpos('.')[2] - b:ht_move.hex_start
  let l:x -= (l:x / ((b:ht_disp.bytes * 2) + 1)) + 1
  if l:x == -1 | let l:x = 0 | endif
  let l:x = (l:x / 2) + (l:x % 2)

	let b:byte_inf = {
				\ 'line': line('.'),
				\ 'nth': l:x,
				\ 'ascii_off': l:x + b:ht_move.ascii_start,
				\ 'hex_off': b:ht_move.hex_start + (l:x * 2) + (l:x / b:ht_disp.bytes)}

	let l:hex_patt = '\%' . line('.') . 'l\%>' . (b:byte_inf.hex_off - 1) 
				\ . 'c\%<' . (b:byte_inf.hex_off + 2) . 'c'
	let l:ascii_patt = '\%' . line('.') . 'l\%' . b:byte_inf.ascii_off . 'c'

	match none
  exec 'match HexThisAsciiEq /' . l:ascii_patt . '/'
  exec '2match HexThisHexEq /' . l:hex_patt . '/'
endfunction

function! s:out_of_bounds()
  let l:pos = getpos('.')
  if l:pos[2] < b:ht_move.hex_start
    let l:pos[2] = b:ht_move.hex_start
  endif
  if l:pos[2] > b:ht_move.hex_end
    let l:pos[2] = b:ht_move.hex_end
  endif
  return l:pos
endfunction

""""""" Movement functions

function! hex_this#move#chunk(dir)
  if index(keys(s:chunk), a:dir) == -1
    throw '[HT] Called <SID>chunk with arg not (g[eE]|[wWbBeE])'
  endif

  exec 'normal! ' . a:dir

  let l:pos = <SID>out_of_bounds()
  let l:x = l:pos[2]
  if l:pos != getpos('.')
    let l:pos[1] += s:chunk[a:dir]
    if s:chunk[a:dir] == 1
      let l:pos[2] = b:ht_move.hex_start
    else
      let l:pos[2] = b:ht_move.hex_end
    endif
  endif

  if l:pos[1] == 0
    let l:pos[1] = 1
    let l:pos[2] = l:x
  endif
  if l:pos[1] == line('$') + 1
    let l:pos[1] = line('$')
    let l:pos[2] = l:x
  endif

  call hex_this#move#curmove(l:pos)
endfunction

function! hex_this#move#hl(dir)
  if index(keys(s:hl), a:dir) == -1
    throw '[HT] Called <SID>hl with arg not [hl]'
  endif

  let l:pos = <SID>out_of_bounds()
  if l:pos != getpos('.')
    call hex_this#move#curmove(l:pos)
    return
  endif

  if l:pos[2] == b:ht_move.hex_start && a:dir == 'h'
    let l:pos[1] = line('.') + s:hl[a:dir]
    let l:pos[2] = b:ht_move.hex_end
    if line('.') != 1
      call hex_this#move#curmove(l:pos)
    endif
    return
  endif

  if l:pos[2] == b:ht_move.hex_end && a:dir == 'l'
    let l:pos[1] = line('.') + s:hl[a:dir]
    let l:pos[2] = b:ht_move.hex_start
    if line('.') != line('$')
      call hex_this#move#curmove(l:pos)
    endif
    return
  endif

  let l:pos[2] += s:hl[a:dir]
  if index(b:ht_move.space_arr, l:pos[2]) != -1
    let l:pos[2] += s:hl[a:dir]
  endif

  call hex_this#move#curmove(l:pos)
endfunction

function! hex_this#move#wb(dir)
  if index(keys(s:wb), a:dir) == -1
    throw '[HT] Called <SID>wb with arg not [wb]'
  endif
	call hex_this#move#hl(s:wb[a:dir])
	call hex_this#move#hl(s:wb[a:dir])
endfunction

function! hex_this#move#jk(dir)
  if index(keys(s:jk), a:dir) == -1
    throw '[HT] Called <SID>jk with arg not [jk]'
  endif
  let l:pos = <SID>out_of_bounds()
  if !((l:pos[1] == 1 && a:dir == 'k') 
				\ || (l:pos[1] == line('$') && a:dir == 'j'))
    let l:pos[1] += s:jk[a:dir]
  endif
  call hex_this#move#curmove(l:pos)
endfunction

function! hex_this#move#rst(...)
	if exists('a:000')
		exec 'normal! ' . join(a:000, ' ')
	endif
  call hex_this#move#curmove(<SID>out_of_bounds())
endfunction

function! hex_this#move#sol()
  call hex_this#move#curmove(
        \ [bufnr(), line('.'), b:ht_move.hex_start, 0])
endfunction

function! hex_this#move#eol()
  call hex_this#move#curmove(
        \ [bufnr(), line('.'), b:ht_move.hex_end, 0])
endfunction

function! hex_this#move#inbound()
	call hex_this#move#curmove(<SID>out_of_bounds())
endfunction

""""""" Display functions

function! hex_this#move#curmove(pos)
  " echo a:pos
  call setpos('.', a:pos)
	if ! b:ht_move.ignore_end && getline('.')[col('.') - 1] == ' '
		normal! gE
	endif
  call hex_this#move#align_hl_groups()
endfunction

" vim: noet ts=2 sw=2 tw=110
