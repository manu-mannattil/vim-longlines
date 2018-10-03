" Vim plugin to navigate through long soft-wrapped lines
" Version: 0.1
" License: Public domain

if exists('g:longlines_loaded') || &compatible || v:version < 700
  finish
endif

let g:longlines_loaded = 1

" List of options that longlines will change.
let s:optkeys = ['colorcolumn', 'formatoptions', 'linebreak', 'cursorline',
      \ 'list', 'relativenumber', 'textwidth', 'wrap', 'wrapmargin']

autocmd VimEnter,VimResized,WinEnter *
      \ let w:longlines_lines = &lines - 2 |
      \ let w:longlines_half_lines = w:longlines_lines / 2

" Function to map keys and save existing mapping (if any).
" Synopsis: s:longlines_map({lhs}, {rhs} [, {mode} [, {arg}]])
function! s:longlines_map(lhs, rhs, ...) abort
  " Mode and additional args (if any).
  let mode = get(a:000, 0, '')
  let arg = get(a:000, 1, '')

  if !has_key(b:mappings, mode . a:lhs)
    let b:mappings[mode . a:lhs] = [a:lhs, maparg(a:lhs, mode), mode]
  endif

  " If we're remapping an insert mode key sequence, we need to check if
  " the ins-completion-menu is visible -- if it's visible we should
  " avoid remapping keys.
  if mode == 'i'
    execute 'inoremap <buffer> <expr>' a:lhs 'pumvisible() ? "' . escape(a:lhs, '"') . '" : "' . escape(a:rhs, '"') . '"'
  else
    execute mode . 'noremap <buffer>' arg a:lhs a:rhs
  endif
endfunction

" Synopsis: s:longlines_on()
function! s:longlines_on() abort
  if exists('b:longlines') && b:longlines == 1
    return
  else
    let b:longlines = 1
  endif

  let b:mappings = {}

  " Save the options we're about to change.
  let b:options = {}
  for key in s:optkeys
    execute 'let b:options[key] = &' . key
  endfor

  " These options aren't useful when the longline mode is on.
  setlocal colorcolumn=
  setlocal formatoptions=jl
  setlocal linebreak
  setlocal nocursorline
  setlocal nolist
  setlocal norelativenumber
  setlocal textwidth=0
  setlocal wrap
  setlocal wrapmargin=0

  " -- General (nvo) mappings -- "

  call s:longlines_map('k', 'gk')
  call s:longlines_map('<Up>', 'gk')
  call s:longlines_map('-', 'gkg^')

  call s:longlines_map('j', 'gj')
  call s:longlines_map('<Down>', 'gj')
  call s:longlines_map('+', 'gj')

  call s:longlines_map('0', 'g0')
  call s:longlines_map('^', 'g^')
  call s:longlines_map('<Home>', 'g<Home>')

  " g_ doesn't make much sense with soft-wrapped lines.
  call s:longlines_map('$', 'g$')
  call s:longlines_map('g_', 'g$')
  call s:longlines_map('<End>', 'g<End>')

  " gg and G work as if startofline is set.
  call s:longlines_map('gg', 'gg^')
  call s:longlines_map('G', 'Gg_')

  " -- Normal mode -- "

  call s:longlines_map('A', 'g$a', 'n')
  call s:longlines_map('I', 'g0i', 'n')

  call s:longlines_map('C', 'cg$', 'n')
  call s:longlines_map('D', 'dg$', 'n')
  call s:longlines_map('Y', 'yg$', 'n')

  " None of the following mappings work properly.  (I'd be glad to know
  " of ways to map them properly).  They don't work with counts,
  " registers, and in general behave differently compared to their usual
  " selves.
  call s:longlines_map('cc', 'strlen(getline("."))>0?"g0cg$":"cc"', 'n', '<expr>')
  call s:longlines_map('dd', 'strlen(getline("."))>0?"g0dg$":"dd"', 'n', '<expr>')
  call s:longlines_map('yy', 'strlen(getline("."))>0?"g0yg$":"yy"', 'n', '<expr>')

  " Visual line mode.
  call s:longlines_map('V', 'g0vg$h', 'n')

  " -- Insert mode -- "

  call s:longlines_map('<Up>', '<C-O>gk', 'i')
  call s:longlines_map('<Down>', '<C-O>gj', 'i')

  call s:longlines_map('<Home>', '<C-O>g<Home>', 'i')
  call s:longlines_map('<End>', '<C-O>g<End>', 'i')

  " -- Scrolling -- "

  " Approximate mouse scrolling in normal/insert mode.
  " By default, Vim scrolls up/down by 3 lines.
  call s:longlines_map('<ScrollWheelUp>', '3gk')
  call s:longlines_map('<ScrollWheelUp>', '<c-o>3gk', 'i')
  call s:longlines_map('<ScrollWheelDown>', '3gj')
  call s:longlines_map('<ScrollWheelDown>', '<c-o>3gj', 'i')

  " Pagewise mouse scrolling.
  call s:longlines_map('<S-ScrollWheelUp>', 'w:longlines_lines . "gk"', '', '<expr>')
  call s:longlines_map('<C-ScrollWheelUp>', 'w:longlines_lines . "gk"', '', '<expr>')
  call s:longlines_map('<S-ScrollWheelDown>', 'w:longlines_lines . "gj"', '', '<expr>')
  call s:longlines_map('<C-ScrollWheelDown>', 'w:longlines_lines . "gj"', '', '<expr>')

  call s:longlines_map('<C-E>', 'gj')
  call s:longlines_map('<C-D>', 'w:longlines_half_lines . "gj"', '', '<expr>')

  call s:longlines_map('<C-Y>', 'gk')
  call s:longlines_map('<C-U>', 'w:longlines_half_lines . "gk"', '', '<expr>')

  call s:longlines_map('<C-F>', 'w:longlines_lines . "gj"', '', '<expr>')
  call s:longlines_map('<S-Down>', 'w:longlines_lines . "gj"', '', '<expr>')
  call s:longlines_map('<PageDown>', 'w:longlines_lines . "gj"', '', '<expr>')

  call s:longlines_map('<C-B>', 'w:longlines_lines . "gk"', '', '<expr>')
  call s:longlines_map('<S-Up>', 'w:longlines_lines . "gk"', '', '<expr>')
  call s:longlines_map('<PageUp>', 'w:longlines_lines . "gk"', '', '<expr>')
endfunction

" Synopsis: s:longlines_off()
function! s:longlines_off() abort
  if exists('b:longlines') && b:longlines == 1
    unlet b:longlines
  else
    return
  endif

  " Restore options.
  for key in s:optkeys
    execute 'let &' . key . ' = b:options[key]'
  endfor

  " Restore mappings.
  for key in keys(b:mappings)
    let value = b:mappings[key]
    if value[1] == ''
      execute value[2] . 'unmap <buffer>' . value[0]
    else
      execute value[2] . 'noremap <buffer> ' . value[0] value[1]
    endif
  endfor

  unlet b:mappings
  unlet b:options
endfunction

" Synopsis: s:longlines_toggle()
function! s:longlines_toggle() abort
  if exists('b:longlines') && b:longlines == 1
    call s:longlines_off()
  else
    call s:longlines_on()
  endif
endfunction

command! -bar -nargs=0 LongLines silent call s:longlines_toggle()
command! -bar -nargs=0 LongLinesOn silent call s:longlines_on()
command! -bar -nargs=0 LongLinesOff silent call s:longlines_off()
