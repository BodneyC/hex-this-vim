let s:hl = { 'h': -1, 'l': 1 }
let s:jk = { 'j': 1, 'k': -1 }
let s:chunk = { 'w': 1, 'W': 1, 'e': 1, 'E': 1,
      \ 'b': -1, 'B': -1, 'ge': -1, 'gE': -1 }

""""""" Util functions

function! s:align_hl_groups()
  let l:x = getpos('.')[2] - b:vht_move.hex_start
  let l:x -= (l:x / ((b:vht_disp.bytes * 2) + 1)) + 1
  if l:x == -1 | let l:x = 0 | endif
  let l:x = (l:x / 2) + (l:x % 2) + b:vht_move.ascii_start
  exec 'match HexThisAsciiEq /\%' . line('.') . 'l\%' . l:x . 'c/'
endfunction

function! s:out_of_bounds()
  let l:pos = getpos('.')
  if l:pos[2] < b:vht_move.hex_start
    let l:pos[2] = b:vht_move.hex_start
  endif
  if l:pos[2] > b:vht_move.hex_end
    let l:pos[2] = b:vht_move.hex_end
  endif
  return l:pos
endfunction

""""""" Movement functions

function! vim_hex_this#move#chunk(dir)
  if index(keys(s:chunk), a:dir) == -1
    throw '[VHT] Called <SID>chunk with arg not (ge|gE|[wWbBeE])'
  endif

  exec 'normal! ' . a:dir

  let l:pos = <SID>out_of_bounds()
  let l:x = l:pos[2]
  if l:pos != getpos('.')
    let l:pos[1] += s:chunk[a:dir]
    if s:chunk[a:dir] == 1
      let l:pos[2] = b:vht_move.hex_start
    else
      let l:pos[2] = b:vht_move.hex_end
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

  call vim_hex_this#move#curmove(l:pos)
endfunction

function! vim_hex_this#move#hl(dir)
  if index(keys(s:hl), a:dir) == -1
    throw '[VHT] Called <SID>hl with arg not [hl]'
  endif

  let l:pos = <SID>out_of_bounds()
  if l:pos != getpos('.')
    call vim_hex_this#move#curmove(l:pos)
    return
  endif

  if l:pos[2] == b:vht_move.hex_start && a:dir == 'h'
    let l:pos[1] = line('.') + s:hl[a:dir]
    let l:pos[2] = b:vht_move.hex_end
    if line('.') != 1
      call vim_hex_this#move#curmove(l:pos)
    endif
    return
  endif

  if l:pos[2] == b:vht_move.hex_end && a:dir == 'l'
    let l:pos[1] = line('.') + s:hl[a:dir]
    let l:pos[2] = b:vht_move.hex_start
    if line('.') != line('$')
      call vim_hex_this#move#curmove(l:pos)
    endif
    return
  endif

  let l:pos[2] += s:hl[a:dir]
  if index(b:vht_move.space_arr, l:pos[2]) != -1
    let l:pos[2] += s:hl[a:dir]
  endif

  call vim_hex_this#move#curmove(l:pos)
endfunction

function! vim_hex_this#move#jk(dir)
  if index(keys(s:jk), a:dir) == -1
    throw '[VHT] Called <SID>jk with arg not [jk]'
  endif

  let l:pos = <SID>out_of_bounds()

  if !((l:pos[1] == 1 && a:dir == 'k') || (l:pos[1] == line('$') && a:dir == 'j'))
    let l:pos[1] += s:jk[a:dir]
  endif

  call vim_hex_this#move#curmove(l:pos)
endfunction

function! vim_hex_this#move#rst(...)
	if exists('a:000')
		exec 'normal! ' . join(a:0, ' ')
	endif
  call vim_hex_this#move#curmove(<SID>out_of_bounds())
endfunction

function! vim_hex_this#move#sol()
  call vim_hex_this#move#curmove(
        \ [bufnr(), line('.'), b:vht_move.hex_start, 0])
endfunction

function! vim_hex_this#move#eol()
  call vim_hex_this#move#curmove(
        \ [bufnr(), line('.'), b:vht_move.hex_end, 0])
endfunction

""""""" Display functions

function! vim_hex_this#move#curmove(pos)
  " echo a:pos
  call setpos('.', a:pos)
  call <SID>align_hl_groups()
endfunction

" vim: noet ts=2 sw=2 tw=110
