" longlines.vim -- Vim plugin to navigate through long wrapped lines.
" Version: 0.1

if exists('g:longlines_loaded') || &compatible || v:version < 700
  finish
endif

let g:longlines_loaded = 1

" List of options that longlines will change.
let s:optkeys = ['colorcolumn', 'formatoptions', 'linebreak', 'cursorline',
      \ 'list', 'relativenumber', 'textwidth', 'wrap', 'wrapmargin']

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
    execute 'inoremap <buffer> <expr>' a:lhs 'pumvisible() ? "' . a:lhs . '" : "' . a:rhs . '"'
  else
    execute mode . 'noremap <buffer>' arg a:lhs a:rhs
  endif
endfunction

" Synopsis: s:longlines_on()
function! s:longlines_on() abort
  if exists('b:longlines')
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

  call s:longlines_map('<up>', '<c-o>gk', 'i')
  call s:longlines_map('<down>', '<c-o>gj', 'i')

  call s:longlines_map('<home>', '<c-o>g<home>', 'i')
  call s:longlines_map('<end>', '<c-o>g<end>', 'i')

  call s:longlines_map('k', 'gk')
  call s:longlines_map('<up>', 'gk')
  call s:longlines_map('-', 'gkg^')

  call s:longlines_map('j', 'gj')
  call s:longlines_map('<down>', 'gj')
  call s:longlines_map('+', 'gj')

  call s:longlines_map('0', 'g0')
  call s:longlines_map('^', 'g^')
  call s:longlines_map('<home>', 'g<home>')

  " g_ doesn't make much sense with soft-wrapped lines.
  call s:longlines_map('$', 'g$')
  call s:longlines_map('g_', 'g$')
  call s:longlines_map('<end>', 'g<end>')

  call s:longlines_map('A', 'g$a', 'n')
  call s:longlines_map('I', 'g0i', 'n')

  call s:longlines_map('C', 'cg$', 'n')
  call s:longlines_map('D', 'dg$', 'n')
  call s:longlines_map('Y', 'yg$', 'n')

  " None of the following mappings work properly.  (I'd be glad to know
  " of ways to map them properly).  They don't work with counts,
  " registers, and in general behave differently compared to their usual
  " selves.
  call s:longlines_map('cc', 'g0cg$', 'n')
  call s:longlines_map('dd', 'g0dg$', 'n')
  call s:longlines_map('yy', 'g0yg$', 'n')

  " Visual line mode.
  call s:longlines_map('V', 'g0vg$h', 'n')

  " gg and G work as if startofline is set.
  call s:longlines_map('gg', 'gg^')
  call s:longlines_map('G', 'Gg_')
endfunction

" Synopsis: s:longlines_off()
function! s:longlines_off() abort
  if exists('b:longlines')
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
  let b:mappings = {}
endfunction

" Synopsis: s:longlines_toggle()
function! s:longlines_toggle() abort
  if exists('b:longlines')
    call s:longlines_off()
  else
    call s:longlines_on()
  endif
endfunction

command! -nargs=0 LongLines silent call s:longlines_toggle()
command! -nargs=0 LongLinesOn silent call s:longlines_on()
command! -nargs=0 LongLinesOff silent call s:longlines_off()
