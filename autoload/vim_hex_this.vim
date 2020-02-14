" let s:max_size = '68719476720'
let s:standard_size = '4294967280'

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
  return l:directory . '/' + substitute(l:fn, '.xxd', '', '')
endfunction

function! s:make_xxd_cmd(fns)
  let l:s  = g:hex_this_xxd_path . ' '
  let l:s .= ' -c ' . b:vht_disp.cols
  let l:s .= ' -g ' . b:vht_disp.bytes
  let l:s .= b:vht_disp.upper ? ' -u ' : ' '
  let l:s .= a:fns.fn
  let l:s .= ' > ' . a:fns.store_fn
  return l:s
endfunction

function! s:setup_buffer(store_fn)
  if ! filereadable(a:store_fn)
    call mkdir(fnamemodify(a:store_fn, ':h'), 'p')
    call system('touch ' . a:store_fn)
  endif
  exec 'edit ' . a:store_fn
  return bufnr()
endfunction

function! s:calculate_space_arr()
	let l:space_arr = []
	let l:x = b:vht_move.hex_start - 1
	while v:true
		let l:x += (b:vht_disp.bytes * 2) + 1
		if l:x > b:vht_move.hex_end
			break
		endif
		call add(l:space_arr, l:x)
	endwhile
	return l:space_arr
endfunction

function! vim_hex_this#init(...) abort " cols, bytes, upper
  call <SID>verify_asides()

  let l:fns = { 'fn': expand('%', ':p') }
  let l:fns.store_fn = g:hex_this_cache_dir . '/' . <SID>encode_fn(l:fns.fn)
  echom l:fns.store_fn

  let l:hex_buf = <SID>setup_buffer(l:fns.store_fn) " Create before setting buffer vars

  let b:vht_disp = {
        \ 'cols': get(a:, '1', g:hex_this_cols),
        \ 'bytes': get(a:, '2', g:hex_this_byte_space),
        \ 'upper': get(a:, '3', g:hex_this_upper)
        \ }

  let l:fsize = getfsize(l:fns.fn)
  if l:fsize > s:standard_size
    throw '[VHT] File very large, best use an actual hex editor...'
  endif
  let l:pos_width = 11

  let b:vht_move = {}
  let b:vht_move.hex_start = l:pos_width
  let b:vht_move.ascii_start = l:pos_width + (b:vht_disp.cols * 2)
        \ + (b:vht_disp.cols / b:vht_disp.bytes)
        \ + (b:vht_disp.cols % b:vht_disp.bytes ? 1 : 0)
        \ + 1
  let b:vht_move.hex_end = b:vht_move.ascii_start - 3
  let b:vht_move.space_arr = <SID>calculate_space_arr()

  let b:vht_init_pos = [bufnr(), 1, b:vht_move.hex_start, 0]

  if getfsize(l:fns.store_fn) == 0
    exec 'r!' . <SID>make_xxd_cmd(l:fns)
    e
    call vim_hex_this#move#curmove(b:vht_init_pos)
  endif
  set ft=xxd

	let b:vht_end_pos = [bufnr(), line('$'), b:vht_move.hex_end, 0]

  call vim_hex_this#mappings#set_mappings()

endfunction

" vim: et ts=2 sw=2 tw=110
