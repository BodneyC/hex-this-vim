let s:n_none_mappings = [ 'cc', 'dd', 'v', 'V', '<C-v>', 'J', 'K',
      \ 'o', 'O', 'D', 'cc', 'p', 'P' ]
let s:i_none_mappings = [ '<BS>', '<Left>', '<Right>', '<Up>', '<Down>' ]

""""""" Mapping functions

function! s:none_mappings(lst, mode)
  for m in a:lst
    exec a:mode . 'noremap <silent><buffer> ' . m . ' <Nop>'
  endfor
endfunction

function! s:func_mapping(mode, key, func, ...)
  let l:args = ''
  if exists('a:000')
    let l:args = join(a:000, ', ')
  endif
  exec a:mode . 'noremap <silent><buffer> ' . a:key . ' :call '
        \ . a:func . '(' . l:args . ')<CR>'
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

  call <SID>func_mapping('n', '<Esc>', 'vim_hex_this#move#inbound')
  call <SID>func_mapping('n', '<C-c>', 'vim_hex_this#move#inbound')

  call <SID>func_mapping('n', 'j',       'vim_hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', '<CR>',    'vim_hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', '+',       'vim_hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', 'k',       'vim_hex_this#move#jk',  '"k"')
  call <SID>func_mapping('n', '-',       'vim_hex_this#move#jk',  '"k"')
  call <SID>func_mapping('n', '<Left>',  'vim_hex_this#move#jk',  '"h"')
  call <SID>func_mapping('n', '<Down>',  'vim_hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', '<Up>',    'vim_hex_this#move#jk',  '"k"')
  call <SID>func_mapping('n', '<Right>', 'vim_hex_this#move#jk',  '"l"')
  call <SID>func_mapping('n', 'h',       'vim_hex_this#move#hl',  '"h"')
  call <SID>func_mapping('n', 'l',       'vim_hex_this#move#hl',  '"l"')
  call <SID>func_mapping('n', 'H',       'vim_hex_this#move#rst', '"H"')
  call <SID>func_mapping('n', 'L',       'vim_hex_this#move#rst', '"L"')

  call <SID>func_mapping('n', 'gg', 'vim_hex_this#move#curmove', b:vht_init_pos)
  call <SID>func_mapping('n', 'G',  'vim_hex_this#move#curmove', b:vht_end_pos)

  call <SID>func_mapping('n', '$',  'vim_hex_this#move#eol')
  call <SID>func_mapping('n', '^',  'vim_hex_this#move#sol')
  call <SID>func_mapping('n', '0',  'vim_hex_this#move#sol')
  call <SID>func_mapping('n', 'g0', 'vim_hex_this#move#sol')
  call <SID>func_mapping('n', '_',  'vim_hex_this#move#sol')

  call <SID>func_mapping('n', 'w', 'vim_hex_this#move#wb', '"w"')
  call <SID>func_mapping('n', 'b', 'vim_hex_this#move#wb', '"b"')

  call <SID>func_mapping('n', 'W',  'vim_hex_this#move#chunk', '"W"')
  call <SID>func_mapping('n', 'e',  'vim_hex_this#move#chunk', '"e"')
  call <SID>func_mapping('n', 'E',  'vim_hex_this#move#chunk', '"E"')
  call <SID>func_mapping('n', 'B',  'vim_hex_this#move#chunk', '"B"')
  call <SID>func_mapping('n', 'ge', 'vim_hex_this#move#chunk', '"ge"')
  call <SID>func_mapping('n', 'gE', 'vim_hex_this#move#chunk', '"gE"')

  call <SID>func_mapping('n', 'r', 'vim_hex_this#edit#change_one')
  call <SID>func_mapping('n', 's', 'vim_hex_this#edit#change_one')
  call <SID>func_mapping('n', 'i', 'vim_hex_this#edit#change_one', '"pick_fmt"')
  call <SID>func_mapping('n', 'I', 'vim_hex_this#edit#move_and_change', 1, '"0"', '"pick_fmt"')
  call <SID>func_mapping('n', 'a', 'vim_hex_this#edit#change_one')
  call <SID>func_mapping('n', 'A', 'vim_hex_this#edit#move_and_change', 1, '"$"', '"pick_fmt"')
  call <SID>func_mapping('n', 'R', 'vim_hex_this#edit#change_many', '"any"')
  call <SID>func_mapping('n', 'S', 'vim_hex_this#edit#move_and_change', 2, '"0"', '"any"')

  call <SID>none_mappings(s:n_none_mappings, 'n')
  call <SID>none_mappings(s:i_none_mappings, 'i')
endfunction
