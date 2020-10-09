" let s:max_size = '68719476720'
let s:standard_size = '4294967280'
let s:pos_width = 11
let s:macunix = has('mac') || has('macunix')

function! s:verify_asides()
  " XXD
  if g:hex_this_xxd_path == '' && executable('xxd')
    let g:hex_this_xxd_path = systemlist('command -v xxd')[0]
  endif
  if ! executable(g:hex_this_xxd_path)
    throw '[HT] XXD not found on path, please set g:hex_this_xxd_path'
  endif

  " base64
  if g:hex_this_base64_path == '' && executable('base64')
    let g:hex_this_base64_path = systemlist('command -v base64')[0]
  endif
  if ! executable(g:hex_this_base64_path)
    throw '[HT] Base64 not found on path, please set g:hex_this_base64_path'
  endif

  " Cache dir
  if ! isdirectory(g:hex_this_cache_dir)
    echom 'Creating cache dir: ' . g:hex_this_cache_dir
    call mkdir(g:hex_this_cache_dir, 'p')
  endif
endfunction

"""""" External commands

function! s:encode_fn(fn)
  let cmd = g:hex_this_base64_path . ' '
  if ! s:macunix
    let cmd .= ' -w 0 '
  endif
  let cmd .= ' <<< ' . fnamemodify(a:fn, ':h')
  let directory = systemlist(cmd)[0]
  return directory . '/' . fnamemodify(a:fn, ':t') . '.xxd'
endfunction

function! s:decode_store_fn(store_fn)
  let fn = substitute(a:store_fn, g:hex_this_cache_dir . '/', '', '')
  let cmd = g:hex_this_base64_path . ' --decode '
  let cmd .= ' <<< ' . fnamemodify(fn, ':h')
  let directory = systemlist(cmd)[0]
  return directory . '/' . substitute(fnamemodify(fn, ':t'), '.xxd', '', '')
endfunction

function! s:make_xxd_read_cmd(fns)
  let s  = g:hex_this_xxd_path . ' '
  let s .= ' -c ' . b:ht_disp.cols
  let s .= ' -g ' . b:ht_disp.bytes
  let s .= b:ht_disp.upper ? ' -u ' : ' '
  let s .= a:fns.fn
  let s .= ' > ' . a:fns.store_fn
  return s
endfunction

function! s:make_xxd_write_cmd(fns, disp)
  let s = g:hex_this_xxd_path . ' -r '
  let s .= ' -c ' . a:disp.cols
  let s .= ' -g ' . a:disp.bytes
  let s .= a:disp.upper ? ' -u ' : ' '
  let s .= a:fns.store_fn . ' > ' . a:fns.fn
  return s
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
  let answer = nr2char(getchar())
  if answer ==? 'y'
    return 1
  elseif answer ==? 'n'
    return 0
  else
    echo 'Please enter "y" or "n"'
    return <SID>confirm(a:msg)
  endif
endfun

function! s:calculate_space_arr()
	let space_arr = []
	let x = b:ht_move.hex_start - 1
	while v:true
		let x += (b:ht_disp.bytes * 2) + 1
		if x > b:ht_move.hex_end
			break
		endif
		call add(space_arr, x)
	endwhile
	return space_arr
endfunction

function! s:guess_disp_inf()
  let line = substitute(getline(1), '^.*: \(.*\)  .*$', '\1', '')
  return {
        \ 'cols': len(substitute(line, ' ', '', 'g')) / 2,
        \ 'bytes': len(substitute(line, '^\([^ ]*\) .*$', '\1', 'g')) / 2,
        \ 'upper': len(substitute(line, '[A-Z]', '', '')) != len(line)
        \ }
endfunction

function! s:set_ht_end_pos()
	let b:ht_end_pos = [bufnr(), line('$'), b:ht_move.hex_end, 0]
endfunction

"""""" Core

function! hex_this#continue() abort
  let fns = { 'store_fn': expand('%:p') }

  if fns.store_fn !~ '^' . g:hex_this_cache_dir . '.*\.xxd'
    echoe fns.store_fn . ' not HexThis file'
  endif

  let fns.fn = <SID>decode_store_fn(fns.store_fn)

  let b:ht_disp = <SID>guess_disp_inf()

  let b:ht_move = {}
  let b:ht_move.ignore_end = v:false
  let b:ht_move.hex_start = s:pos_width
  let b:ht_move.ascii_start = s:pos_width + (b:ht_disp.cols * 2)
        \ + (b:ht_disp.cols / b:ht_disp.bytes)
        \ + ((b:ht_disp.cols % b:ht_disp.bytes) ? 1 : 0)
        \ + 1
  let b:ht_move.hex_end = b:ht_move.ascii_start - 3
  let b:ht_move.space_arr = <SID>calculate_space_arr()

  call hex_this#move#inbound()

  call <SID>set_ht_end_pos()

  call hex_this#mappings#set_mappings()
endfunction

function! hex_this#init(...) abort " cols, bytes, upper
  call <SID>verify_asides()

  let fns = { 'fn': expand('%:p') }
  let fns.store_fn = g:hex_this_cache_dir . '/' . <SID>encode_fn(fns.fn)

  let hex_buf = <SID>setup_buffer(fns.store_fn) " Create before setting buffer vars

  let b:ht_disp = {
        \ 'cols': get(a:, '1', g:hex_this_cols),
        \ 'bytes': get(a:, '2', g:hex_this_byte_space),
        \ 'upper': get(a:, '3', g:hex_this_upper)
        \ }

  let fsize = getfsize(fns.fn)
  if fsize > s:standard_size
    throw '[HT] File very large, best use an actual hex editor...'
  endif

  let b:ht_move = {}
  let b:ht_move.ignore_end = v:false
  let b:ht_move.hex_start = s:pos_width
  let b:ht_move.ascii_start = s:pos_width + (b:ht_disp.cols * 2)
        \ + (b:ht_disp.cols / b:ht_disp.bytes)
        \ + ((b:ht_disp.cols % b:ht_disp.bytes) ? 1 : 0)
        \ + 1
  let b:ht_move.hex_end = b:ht_move.ascii_start - 3
  let b:ht_move.space_arr = <SID>calculate_space_arr()

  let b:ht_init_pos = [bufnr(), 1, b:ht_move.hex_start, 0]

  if getfsize(fns.store_fn) == 0
    exec 'r!' . <SID>make_xxd_read_cmd(fns)
    e
    call hex_this#move#curmove(b:ht_init_pos)
  else
    let b:ht_disp = <SID>guess_disp_inf()
  endif

  call hex_this#move#inbound()

  call <SID>set_ht_end_pos()

  call hex_this#mappings#set_mappings()
endfunction

function! hex_this#reset(...) abort " as init
  call <SID>verify_asides()
  let fns = { 'fn': expand('%:p') }
  let fns.store_fn = g:hex_this_cache_dir . '/' . <SID>encode_fn(fns.fn)
  call delete(fns.store_fn)
  exec 'call hex_this#init(' . join(a:000, ', ') . ')'
endfunction

function! hex_this#write(...) abort
  call <SID>verify_asides()

  if expand('%') !~# '\.xxd$'
    echo '[HT] Not an .xxd file'
    return
  endif

  let disp = {
        \ 'cols': get(a:, '1', g:hex_this_cols),
        \ 'bytes': get(a:, '2', g:hex_this_byte_space),
        \ 'upper': get(a:, '3', g:hex_this_upper)
        \ }

  if empty(a:000)
    let disp = <SID>guess_disp_inf()
  endif

  if &modified | w | endif

  let fns = { 'store_fn': expand('%:p') }

  if fns.store_fn !~# '^' . g:hex_this_cache_dir
    throw '[HT] File not found in g:hex_this_cache_dir (' . fns.store_fn . ')'
  endif

  let fns.fn = <SID>decode_store_fn(fns.store_fn)

  call system(<SID>make_xxd_write_cmd(fns, disp))
  echom <SID>make_xxd_write_cmd(fns, disp)

  exec 'edit ' . fns.fn

  if <SID>confirm('Delete ' . fns.store_fn . ' [yn]?')
    call delete(fns.store_fn)
    for bufnr in filter(range(1, bufnr('$')), 'bufexists(v:val)')
      if fnamemodify(bufname(bufnr), ':p') == fns.store_fn
        try
          exec 'bdelete! ' . bufnr
        catch /^E94.*/
          echo '[HT] Buffer ' . bufnr . ' not found'
        endtry
      endif
    endfor
  endif
endfunction

function! hex_this#add_lines(...) abort
  if expand('%') !~# '\.xxd$'
    echo '[HT] Not an .xxd file'
    return
  endif

  let disp = <SID>guess_disp_inf()
  let lines = get(a:, '1', g:hex_this_n_lines)

  if lines == 0 | return | endif

  let hpos = str2nr(substitute(getline('$'), ':.*$', '', ''), 16)

  let l1 = getline(1)
  let mid = substitute(l1, '^.*: \(.\{-}\)  .*$', '\=repeat("0", len(submatch(1)))', '')
  let mid = substitute(mid, '\(' . repeat('.', disp.bytes * 2) . '\).', '\1 ', 'g')
  let blanks = mid . '  ' . substitute(l1, '^.\{-}  \(.*\)$', '\=repeat(".", len(submatch(1)))', '')

  let diff = len(l1) - len(getline('$'))
  if diff
    exec 'normal! GA' . repeat('.', diff)
    let ll = getline('$')
    let llm = substitute(ll, '^.*: \(.\{-\}\)\(  .*\)  .*$', '\=join([submatch(1), repeat("0", len(submatch(2)))], "")', '')
    let llm = substitute(llm, '\(' . repeat('.', disp.bytes * 2) . '\).', '\1 ', 'g')
    let ll = substitute(ll, ': .*  \([^ ]\)', ': ' . llm . '  \1', '')
    exec 'normal! Gdd'
    call append(line('$'), ll)
  endif

  for i in range(lines)
    let hpos += disp.cols
    let ln = printf('%08x', hpos) . ': ' . blanks
    call append(line('$'), ln)
  endfor

endfunction

function! hex_this#add_bytes(...) abort
  if ! exists('b:ht_move')
    echo '[HT] File not loaded with HT'
    return
  endif

  let disp = <SID>guess_disp_inf()
  let bytes = get(a:, '1', g:hex_this_n_bytes)

  if bytes == 0 | return | endif

  let diff = len(getline(1)) - len(getline('$'))
  let n_lines = 0
  let mod = bytes

  if bytes > diff + b:ht_disp.cols
    let n_lines = (bytes - diff) / b:ht_disp.cols
    let mod = (bytes - diff) % b:ht_disp.cols
  endif

  call hex_this#add_lines(n_lines)

  for i in range(mod)
    let diff = len(getline(1)) - len(getline('$'))
    if diff
      normal! GA.
      normal G
      let b:ht_move.ignore_end = v:true
      normal l
      let b:ht_move.ignore_end = v:false
      normal! R00
    else
      let l1 = getline(1)
      let mid = '00' . substitute(l1, '^.*: \(.\{-}\)  .*$', '\=repeat(" ", len(submatch(1)))', '')[2:]
      let hpos = str2nr(substitute(getline('$'), ':.*$', '', ''), 16) + disp.cols
      let ln = printf('%08x', hpos) . ': ' . mid . '  .'
      call append(line('$'), ln)
      call <SID>set_ht_end_pos()
    endif
  endfor

endfunction

" vim: et ts=2 sw=2 tw=110
