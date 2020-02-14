let s:n_none_mappings = [ 'S', 'cc', 'dd', 'v', 'V', 'J', 'K' ]
let s:i_none_mappings = [ '<BS>', '<Left>', '<Right>', '<Up>', '<Down>' ]

""""""" Mapping functions

function! s:none_mappings(lst, mode)
  for m in a:lst
    exec a:mode . 'noremap <silent><buffer> ' . m . ' <Nop>'
  endfor
endfunction

function! s:func_mapping(mode, key, func, ...)
  exec a:mode . 'noremap <silent><buffer> ' . a:key . ' :call '
        \ . a:func . '(' . join(a:000, ', ') . ')<CR>'
endfunction

function! s:key_mapping(mode, key_from, key_to)
  exec a:mode . 'noremap <silent><buffer> ' . a:key_from . ' ' . a:key_to
endfunction

""""""" Core

function! vim_hex_this#mappings#set_mappings() abort
  if ! exists('b:vht_disp') || ! exists('b:vht_move')
    throw '[VHT] Cannot set mapping if buffer opts are not set'
  endif

  mapclear!
  mapclear! <buffer>

  call <SID>func_mapping('n', '<Esc>', 'vim_hex_this#move#curmove', 'getpos(".")')
  call <SID>func_mapping('n', 'h', 'vim_hex_this#move#hl', '"h"')
  call <SID>func_mapping('n', 'j', 'vim_hex_this#move#jk', '"j"')
  call <SID>func_mapping('n', '<CR>', 'vim_hex_this#move#jk', '"j"')
  call <SID>func_mapping('n', 'k', 'vim_hex_this#move#jk', '"k"')
  call <SID>func_mapping('n', 'l', 'vim_hex_this#move#hl', '"l"')
  call <SID>func_mapping('n', 'H', 'vim_hex_this#move#rst', '"H"')
  call <SID>func_mapping('n', 'L', 'vim_hex_this#move#rst', '"L"')
  call <SID>func_mapping('n', 'gg', 'vim_hex_this#move#curmove', b:vht_init_pos)
  call <SID>func_mapping('n', 'G', 'vim_hex_this#move#curmove', b:vht_end_pos)
  call <SID>func_mapping('n', '$', 'vim_hex_this#move#eol')
  call <SID>func_mapping('n', '^', 'vim_hex_this#move#sol')
  call <SID>func_mapping('n', '0', 'vim_hex_this#move#sol')
  call <SID>func_mapping('n', 'g0', 'vim_hex_this#move#sol')
  call <SID>func_mapping('n', '_', 'vim_hex_this#move#sol')
  call <SID>func_mapping('n', 'w',  'vim_hex_this#move#chunk', '"w"')
  call <SID>func_mapping('n', 'W',  'vim_hex_this#move#chunk', '"W"')
  call <SID>func_mapping('n', 'e',  'vim_hex_this#move#chunk', '"e"')
  call <SID>func_mapping('n', 'E',  'vim_hex_this#move#chunk', '"E"')
  call <SID>func_mapping('n', 'b',  'vim_hex_this#move#chunk', '"b"')
  call <SID>func_mapping('n', 'B',  'vim_hex_this#move#chunk', '"B"')
  call <SID>func_mapping('n', 'ge', 'vim_hex_this#move#chunk', '"ge"')
  call <SID>func_mapping('n', 'gE', 'vim_hex_this#move#chunk', '"gE"')

  call <SID>key_mapping('n', '<Left>', 'h')
  call <SID>key_mapping('n', '<Down>', 'j')
  call <SID>key_mapping('n', '<Up>', 'k')
  call <SID>key_mapping('n', '<Right>', 'l')

  " call <SID>func_mapping('n', 'i')
  " call <SID>func_mapping('n', 'I')
  " call <SID>func_mapping('n', 'a')
  " call <SID>func_mapping('n', 'A')
  " call <SID>func_mapping('n', 'i')
  " call <SID>func_mapping('n', 's')

  call <SID>none_mappings(s:n_none_mappings, 'n')
  call <SID>none_mappings(s:i_none_mappings, 'i')
endfunction
