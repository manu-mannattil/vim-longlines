" Vim plugin to navigate through long soft-wrapped lines
" Version: 0.1
" License: Public domain

if exists('g:longlines_loaded') || &compatible || v:version < 700
  finish
endif

let g:longlines_loaded = 1

" List of options that longlines will change.
let s:optkeys = ['colorcolumn', 'formatoptions', 'linebreak', 'textwidth', 'wrap', 'wrapmargin']

augroup longlines
  autocmd!
  autocmd OptionSet,VimEnter,VimResized,WinEnter *
        \ let w:longlines_lines = winheight(0)          |
        \ let w:longlines_half_lines = winheight(0) / 2 |
        \ let w:longlines_columns = s:longlines_width()
augroup END

" Synopsis: s:longlines_width()
" https://stackoverflow.com/q/26315925
function! s:longlines_width()
  redir! => sign_list | execute 'silent sign place buffer='.bufnr('%') | redir END
  let number_width = max([&numberwidth, strlen(line('$')) + 1])
  return winwidth(0)
              \ - &foldcolumn
              \ - ((&number || &relativenumber) ? number_width : 0)
              \ - (sign_list =~# '^\n[^\n]*\n$' ? 0 : 2)
endfunction

" Function to map keys and save existing mapping (if any).
" Synopsis: s:longlines_map({lhs}, {rhs}, {mode}, {expr})
function! s:longlines_map(lhs, rhs, mode, expr) abort
  " b:map_restore is a list of expressions that when executed restores all
  " previous mappings.  Since <buffer> mappings have precedence over other
  " mappings, we have to always unmap the mappings we make.
  let b:map_restore += [a:mode.'unmap <buffer>'.a:lhs]
  let map_dict = maparg(a:lhs, a:mode, 0, 1)

  if !empty(map_dict)
    " https://vi.stackexchange.com/a/7735
    let b:map_restore += [
          \   ('nvoicsxlt' =~ map_dict.mode ? map_dict.mode :     '')
          \ . (map_dict.noremap             ? 'noremap   '  : 'map ')
          \ . (map_dict.buffer              ? ' <buffer> '  :     '')
          \ . (map_dict.expr                ? ' <expr>   '  :     '')
          \ . (map_dict.nowait              ? ' <nowait> '  :     '')
          \ . (map_dict.silent              ? ' <silent> '  :     '')
          \ .  map_dict.lhs
          \ .  ' '
          \ .  substitute(map_dict.rhs, '<SID>', '<SNR>'.map_dict.sid.'_', 'g')
          \ ]
  endif

  execute a:mode.'noremap <silent> <buffer>' (a:expr?'<expr>':'') a:lhs a:rhs
endfunction

" Synopsis: s:longlines_on()
function! s:longlines_on() abort
  if exists('b:longlines') && b:longlines == 1
    return
  else
    let b:longlines = 1
  endif

  let b:map_restore = []

  " Save the options we're about to change.
  let b:options = {}
  for key in s:optkeys
    execute 'let b:options[key] = &'.key
  endfor

  " Remove all formatoptions that lead to automatic hardwrapping of
  " input text.
  for letter in split('1,2,a,b,c,m,t,v', ',')
    execute 'setlocal formatoptions-='.letter
  endfor
  setlocal formatoptions+=l

  " These options aren't useful when the longline mode is on.
  setlocal colorcolumn=
  setlocal linebreak
  setlocal wrap
  setlocal wrapmargin=0

  " -- General (nvo) mappings -- "

  call s:longlines_map('k', 'gk', '', 0)
  call s:longlines_map('<Up>', 'gk', '', 0)
  call s:longlines_map('-', 'gkg^', '', 0)

  call s:longlines_map('j', 'gj', '', 0)
  call s:longlines_map('<Down>', 'gj', '', 0)
  call s:longlines_map('+', 'gj', '', 0)

  call s:longlines_map('0', 'g0', '', 0)
  call s:longlines_map('^', 'g^', '', 0)
  call s:longlines_map('<Home>', 'g<Home>', '', 0)

  " g_ doesn't make much sense with soft-wrapped lines.
  call s:longlines_map('$', 'g$', '', 0)
  call s:longlines_map('g_', 'g$', '', 0)
  call s:longlines_map('<End>', 'g<End>', '', 0)

  " gg and G work as if startofline is set.
  call s:longlines_map('gg', 'gg^', '', 0)
  call s:longlines_map('<C-Home>', 'gg^', '', 0)
  call s:longlines_map('G', 'Gg_g^', '', 0)
  call s:longlines_map('<C-End>', 'Gg_', '', 0)

  " -- Normal mode -- "

  call s:longlines_map('A', 'g$a', 'n', 0)
  call s:longlines_map('I', 'g0i', 'n', 0)

  call s:longlines_map('C', 'cg$', 'n', 0)
  call s:longlines_map('D', 'dg$', 'n', 0)
  call s:longlines_map('Y', 'yg$', 'n', 0)

  " None of the following mappings work properly.  (I'd be glad to know of ways
  " to map them properly.)  They don't work with counts, registers, and in
  " general behave differently compared to their usual selves.
  call s:longlines_map('cc', 'w:longlines_columns<strlen(getline("."))?"g0cg$":"cc"', 'n', 1)
  call s:longlines_map('dd', 'w:longlines_columns<strlen(getline("."))?"g0dg$":"dd"', 'n', 1)
  call s:longlines_map('yy', 'w:longlines_columns<strlen(getline("."))?"g0yg$":"yy"', 'n', 1)

  " Visual line mode.
  call s:longlines_map('V', 'g0vg$h', 'n', 0)

  " -- Insert mode -- "

  " If we're remapping an insert mode key sequence, we need to check if the
  " ins-completion-menu is visible -- if it's visible we should avoid remapping
  " keys.
  call s:longlines_map('<Up>', 'pumvisible()?"<Up>":"<C-O>gk"', 'i', 1)
  call s:longlines_map('<Down>', 'pumvisible()?"<Down>":"<C-O>gj"', 'i', 1)
  call s:longlines_map('<Home>', '<C-O>g<Home>', 'i', 0)
  call s:longlines_map('<End>', '<C-O>g<End>', 'i', 0)

  " -- Scrolling -- "

  " Approximate mouse scrolling in normal/insert mode.
  " By default, Vim scrolls up/down by 3 lines.
  call s:longlines_map('<ScrollWheelUp>', '3gk', '', 0)
  call s:longlines_map('<ScrollWheelUp>', '<C-O>3gk', 'i', 0)
  call s:longlines_map('<ScrollWheelDown>', '3gj', '', 0)
  call s:longlines_map('<ScrollWheelDown>', '<C-O>3gj', 'i', 0)

  " Pagewise mouse scrolling.
  call s:longlines_map('<S-ScrollWheelUp>', 'w:longlines_lines."gk"', '', 1)
  call s:longlines_map('<C-ScrollWheelUp>', 'w:longlines_lines."gk"', '', 1)
  call s:longlines_map('<S-ScrollWheelDown>', 'w:longlines_lines."gj"', '', 1)
  call s:longlines_map('<C-ScrollWheelDown>', 'w:longlines_lines."gj"', '', 1)

  call s:longlines_map('<C-E>', 'gj', '', 0)
  call s:longlines_map('<C-D>', 'v:count?"gj":w:longlines_half_lines."gj"', '', 1)

  call s:longlines_map('<C-Y>', 'gk', '', 0)
  call s:longlines_map('<C-U>', 'v:count?"gk":w:longlines_half_lines."gk"', '', 1)

  call s:longlines_map('<C-F>', 'w:longlines_lines."gj"', '', 1)
  call s:longlines_map('<S-Down>', 'w:longlines_lines."gj"', '', 1)
  call s:longlines_map('<S-Down>', 'pumvisible()?"<S-Down>":"<Esc>".w:longlines_lines."gji"', 'i', 1)
  call s:longlines_map('<PageDown>', 'w:longlines_lines."gj"', '', 1)
  call s:longlines_map('<PageDown>', 'pumvisible()?"<PageDown>":"<Esc>".w:longlines_lines."gji"', 'i', 1)

  call s:longlines_map('<C-B>', 'w:longlines_lines."gk"', '', 1)
  call s:longlines_map('<S-Up>', 'w:longlines_lines."gk"', '', 1)
  call s:longlines_map('<S-Up>', 'pumvisible()?"<S-Up>":"<Esc>".w:longlines_lines."gki"', 'i', 1)
  call s:longlines_map('<PageUp>', 'w:longlines_lines."gk"', '', 1)
  call s:longlines_map('<PageUp>', 'pumvisible()?"<PageUp>":"<Esc>".w:longlines_lines."gki"', 'i', 1)
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
    execute 'let &'.key.' = b:options[key]'
  endfor
  unlet b:options

  " Restore mappings.
  for expr in b:map_restore
    execute expr
  endfor
  unlet b:map_restore
endfunction

" Synopsis: s:longlines({bang})
function! s:longlines(bang) abort
  if a:bang
    call s:longlines_off()
  else
    if exists('b:longlines') && b:longlines == 1
      call s:longlines_off()
    else
      call s:longlines_on()
    endif
  endif
endfunction

command! -bang -bar -nargs=0 LongLines silent call s:longlines(<bang>0)
