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

function! s:seq_mapping(mode, key, ...)
  let l:args = ''
  if exists('a:000')
    let l:args = join(a:000, ' | ')
  endif
  exec a:mode . 'noremap <silent><buffer> ' . a:key . ' ' . l:args . '<CR>'
endfunction

function! s:key_mapping(mode, key_from, key_to)
  exec a:mode . 'noremap <silent><buffer> ' . a:key_from . ' ' . a:key_to
endfunction

""""""" Core

function! hex_this#mappings#set_mappings() abort
  if ! exists('b:ht_disp') || ! exists('b:ht_move')
    throw '[HT] Cannot set mapping if buffer opts are not set'
  endif

  mapclear!
  mapclear! <buffer>

  call <SID>func_mapping('n', '<Esc>',       'hex_this#move#inbound')
  call <SID>func_mapping('n', '<C-c>',       'hex_this#move#inbound')
  call <SID>seq_mapping('',   '<LeftMouse>', '<LeftMouse>:call hex_this#move#inbound()')

  call <SID>func_mapping('n', 'j',       'hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', '<CR>',    'hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', '+',       'hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', 'k',       'hex_this#move#jk',  '"k"')
  call <SID>func_mapping('n', '-',       'hex_this#move#jk',  '"k"')
  call <SID>func_mapping('n', '<Down>',  'hex_this#move#jk',  '"j"')
  call <SID>func_mapping('n', '<Up>',    'hex_this#move#jk',  '"k"')
  call <SID>func_mapping('n', '<Left>',  'hex_this#move#hl',  '"h"')
  call <SID>func_mapping('n', '<Right>', 'hex_this#move#hl',  '"l"')
  call <SID>func_mapping('n', 'h',       'hex_this#move#hl',  '"h"')
  call <SID>func_mapping('n', 'l',       'hex_this#move#hl',  '"l"')
  call <SID>func_mapping('n', 'H',       'hex_this#move#rst', '"H"')
  call <SID>func_mapping('n', 'L',       'hex_this#move#rst', '"L"')

  call <SID>func_mapping('n', 'gg', 'hex_this#move#curmove', 'b:ht_init_pos')
  call <SID>func_mapping('n', 'G',  'hex_this#move#curmove', 'b:ht_end_pos')

  call <SID>func_mapping('n', '$',  'hex_this#move#eol')
  call <SID>func_mapping('n', '^',  'hex_this#move#sol')
  call <SID>func_mapping('n', '0',  'hex_this#move#sol')
  call <SID>func_mapping('n', 'g0', 'hex_this#move#sol')
  call <SID>func_mapping('n', '_',  'hex_this#move#sol')

  call <SID>func_mapping('n', 'w', 'hex_this#move#wb', '"w"')
  call <SID>func_mapping('n', 'b', 'hex_this#move#wb', '"b"')

  call <SID>func_mapping('n', 'W',  'hex_this#move#chunk', '"W"')
  call <SID>func_mapping('n', 'e',  'hex_this#move#chunk', '"e"')
  call <SID>func_mapping('n', 'E',  'hex_this#move#chunk', '"E"')
  call <SID>func_mapping('n', 'B',  'hex_this#move#chunk', '"B"')
  call <SID>func_mapping('n', 'ge', 'hex_this#move#chunk', '"ge"')
  call <SID>func_mapping('n', 'gE', 'hex_this#move#chunk', '"gE"')

  call <SID>func_mapping('n', 'r', 'hex_this#edit#change_one')
  call <SID>func_mapping('n', 's', 'hex_this#edit#change_one')
  call <SID>func_mapping('n', 'i', 'hex_this#edit#change_one', '"pick_fmt"')
  call <SID>func_mapping('n', 'I', 'hex_this#edit#move_and_change', 1, '"pick_fmt"', '"0"')
  call <SID>func_mapping('n', 'a', 'hex_this#edit#change_one')
  call <SID>func_mapping('n', 'A', 'hex_this#edit#func_and_change', 1, '"pick_fmt"', '"hex_this#add_bytes"', '"1"')
  call <SID>func_mapping('n', 'R', 'hex_this#edit#change_many', '"any"')
  call <SID>func_mapping('n', 'S', 'hex_this#edit#move_and_change', 2, '"any"', '"0"')

  call <SID>none_mappings(s:n_none_mappings, 'n')
  call <SID>none_mappings(s:i_none_mappings, 'i')
endfunction
