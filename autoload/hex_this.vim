" let s:max_size = '68719476720'
let s:standard_size = '4294967280'
let s:pos_width = 11

function! s:verify_asides()
  " XXD
  if g:hex_this_xxd_path == '' && executable('xxd')
    let g:hex_this_xxd_path = systemlist('command -v xxd')[0]
  endif
  if ! executable(g:hex_this_xxd_path)
    throw '[VHT] XXD not found on path, please set g:hex_this_xxd_path'
  endif

  " base64
  if g:hex_this_base64_path == '' && executable('base64')
    let g:hex_this_base64_path = systemlist('command -v base64')[0]
  endif
  if ! executable(g:hex_this_base64_path)
    throw '[VHT] Base64 not found on path, please set g:hex_this_base64_path'
  endif

  " Cache dir
  if ! isdirectory(g:hex_this_cache_dir)
    echom 'Creating cache dir: ' . g:hex_this_cache_dir
    call mkdir(g:hex_this_cache_dir, 'p')
  endif
endfunction

"""""" External commands

function! s:encode_fn(fn)
  let l:cmd = g:hex_this_base64_path . ' '
  if has('unix')
    let l:cmd .= ' -w 0 '
  endif
  let l:cmd .= ' <<< ' . fnamemodify(a:fn, ':h')
  let l:directory = systemlist(l:cmd)[0]
  return l:directory . '/' . fnamemodify(a:fn, ':t') . '.xxd'
endfunction

function! s:decode_store_fn(store_fn)
  let l:fn = substitute(a:store_fn, g:hex_this_cache_dir . '/', '', '')
  let l:cmd = g:hex_this_base64_path . ' --decode '
  let l:cmd .= ' <<< ' . fnamemodify(l:fn, ':h')
  let l:directory = systemlist(l:cmd)[0]
  return l:directory . '/' . substitute(fnamemodify(l:fn, ':t'), '.xxd', '', '')
endfunction

function! s:make_xxd_read_cmd(fns)
  let l:s  = g:hex_this_xxd_path . ' '
  let l:s .= ' -c ' . b:ht_disp.cols
  let l:s .= ' -g ' . b:ht_disp.bytes
  let l:s .= b:ht_disp.upper ? ' -u ' : ' '
  let l:s .= a:fns.fn
  let l:s .= ' > ' . a:fns.store_fn
  return l:s
endfunction

function! s:make_xxd_write_cmd(fns, disp)
  let l:s = g:hex_this_xxd_path . ' -r '
  let l:s .= ' -c ' . a:disp.cols
  let l:s .= ' -g ' . a:disp.bytes
  let l:s .= a:disp.upper ? ' -u ' : ' '
  let l:s .= a:fns.store_fn . ' > ' . a:fns.fn
  return l:s
endfunction

"""""" Utility

function! s:setup_buffer(store_fn)
  if ! filereadable(a:store_fn)
    call mkdir(fnamemodify(a:store_fn, ':h'), 'p')
    call system('touch ' . a:store_fn)
  endif
  exec 'edit ' . a:store_fn
  return bufnr()
endfunction

function s:confirm(msg)
  redraw
  echom a:msg . ' '
  let l:answer = nr2char(getchar())
  if l:answer ==? 'y'
    return 1
  elseif l:answer ==? 'n'
    return 0
  else
    echo 'Please enter "y" or "n"'
    return <SID>confirm(a:msg)
  endif
endfun

function! s:calculate_space_arr()
	let l:space_arr = []
	let l:x = b:ht_move.hex_start - 1
	while v:true
		let l:x += (b:ht_disp.bytes * 2) + 1
		if l:x > b:ht_move.hex_end
			break
		endif
		call add(l:space_arr, l:x)
	endwhile
	return l:space_arr
endfunction

function! s:guess_disp_inf()
  let l:line = substitute(getline(1), '^.*: \(.*\)  .*$', '\1', '')
  return {
        \ 'cols': len(substitute(l:line, ' ', '', 'g')) / 2,
        \ 'bytes': len(substitute(l:line, '^\([^ ]*\) .*$', '\1', 'g')) / 2,
        \ 'upper': len(substitute(l:line, '[A-Z]', '', '')) != len(l:line)
        \ }
endfunction

"""""" Core

function! hex_this#init(...) abort " cols, bytes, upper
  call <SID>verify_asides()

  let l:fns = { 'fn': expand('%:p') }
  let l:fns.store_fn = g:hex_this_cache_dir . '/' . <SID>encode_fn(l:fns.fn)

  let l:hex_buf = <SID>setup_buffer(l:fns.store_fn) " Create before setting buffer vars

  let b:ht_disp = {
        \ 'cols': get(a:, '1', g:hex_this_cols),
        \ 'bytes': get(a:, '2', g:hex_this_byte_space),
        \ 'upper': get(a:, '3', g:hex_this_upper)
        \ }

  let l:fsize = getfsize(l:fns.fn)
  if l:fsize > s:standard_size
    throw '[VHT] File very large, best use an actual hex editor...'
  endif

  let b:ht_move = {}
  let b:ht_move.hex_start = s:pos_width
  let b:ht_move.ascii_start = s:pos_width + (b:ht_disp.cols * 2)
        \ + (b:ht_disp.cols / b:ht_disp.bytes)
        \ + ((b:ht_disp.cols % b:ht_disp.bytes) ? 1 : 0)
        \ + 1
  let b:ht_move.hex_end = b:ht_move.ascii_start - 3
  let b:ht_move.space_arr = <SID>calculate_space_arr()

  let b:ht_init_pos = [bufnr(), 1, b:ht_move.hex_start, 0]

  if getfsize(l:fns.store_fn) == 0
    exec 'r!' . <SID>make_xxd_read_cmd(l:fns)
    e
    call hex_this#move#curmove(b:ht_init_pos)
  else
    let b:ht_disp = <SID>guess_disp_inf()
  endif

  set ft=xxd
  call hex_this#move#inbound()

	let b:ht_end_pos = [bufnr(), line('$'), b:ht_move.hex_end, 0]

  call hex_this#mappings#set_mappings()
endfunction

function! hex_this#reset(...) abort " as init
  call <SID>verify_asides()
  let l:fns = { 'fn': expand('%:p') }
  let l:fns.store_fn = g:hex_this_cache_dir . '/' . <SID>encode_fn(l:fns.fn)
  call delete(l:fns.store_fn)
  exec 'call hex_this#init(' . join(a:000, ', ') . ')'
endfunction

function! hex_this#write(...) abort
  call <SID>verify_asides()

  if expand('%') !~# '\.xxd$'
    echo '[VHT] Not an .xxd file'
    return
  endif

  let l:disp = {
        \ 'cols': get(a:, '1', g:hex_this_cols),
        \ 'bytes': get(a:, '2', g:hex_this_byte_space),
        \ 'upper': get(a:, '3', g:hex_this_upper)
        \ }

  if empty(a:000)
    let l:disp = <SID>guess_disp_inf()
  endif

  if &modified | w | endif

  let l:fns = { 'store_fn': expand('%:p') }

  if l:fns.store_fn !~# '^' . g:hex_this_cache_dir
    throw '[VHT] File not found in g:hex_this_cache_dir (' . l:fns.store_fn . ')'
  endif

  let l:fns.fn = <SID>decode_store_fn(l:fns.store_fn)

  call system(<SID>make_xxd_write_cmd(l:fns, l:disp))
  echom <SID>make_xxd_write_cmd(l:fns, l:disp)

  exec 'edit ' . l:fns.fn

  if <SID>confirm('Delete ' . l:fns.store_fn . ' [yn]?')
    call delete(l:fns.store_fn)
    for l:bufnr in filter(range(1, bufnr('$')), 'bufexists(v:val)')
      if fnamemodify(bufname(l:bufnr), ':p') == l:fns.store_fn
        try
          exec 'bdelete! ' . l:bufnr
        catch /^E94.*/
          echo '[VHT] Buffer ' . l:bufnr . ' not found'
        endtry
      endif
    endfor
  endif
endfunction

function! hex_this#add_lines(...) abort
  if expand('%') !~# '\.xxd$'
    echo '[VHT] Not an .xxd file'
    return
  endif

  let l:disp = <SID>guess_disp_inf()
  let l:lines = get(a:, '1', g:hex_this_n_lines)

  let l:hpos = str2nr(substitute(getline('$'), ':.*$', '', ''), 16)

  let l:l1 = getline(1)
  let l:mid = substitute(l:l1, '^.*: \(.*\)  .*$', '\=repeat("0", len(submatch(1)))', '')
  let l:mid = substitute(l:mid, '\(' . repeat('.', l:disp.bytes * 2) . '\).', '\1 ', 'g')
  let l:blanks = l:mid
        \ . '  '
        \ . substitute(l:l1, '^.*  \(.*\)$', '\=repeat(".", len(submatch(1)))', '')

  let l:diff = len(l:l1) - len(getline('$'))
  if l:diff
    exec 'normal! GA' . repeat('.', l:diff)
    let l:ll = getline('$')
    let l:llm = substitute(l:ll, '^.*: \(.\{-\}\)\(  .*\)  .*$', '\=join([submatch(1), repeat("0", len(submatch(2)))], "")', '')
    let l:llm = substitute(l:llm, '\(' . repeat('.', l:disp.bytes * 2) . '\).', '\1 ', 'g')
    let l:ll = substitute(l:ll, ': .*  \([^ ]\)', ': ' . l:llm . '  \1', '')
    exec 'normal! Gdd'
    call append(line('$'), l:ll)
  endif

  for l:i in range(l:lines)
    let l:hpos += l:disp.cols
    let l:ln = printf('%08x', l:hpos) . ': ' . l:blanks
    call append(line('$'), l:ln)
  endfor

endfunction

" vim: et ts=2 sw=2 tw=110
