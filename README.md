vim-longlines
=============

A Vim plugin to help navigate through long wrapped lines.

Usage
-----

longlines.vim defines three commands:

  1. `LongLinesOn`, which turns on the longline mode.
  2. `LongLinesOff`, which turns off the longline mode and restores
      previous mappings (if any).
  3. `LongLines`, which toggles the longline mode.

When the longline mode is on, motion commands such as `j`, `k`, `gg`,
`G`, etc., work on display lines rather than actual lines.  Although the
longline mode replicates most commands reasonably well, some mappings
(e.g., `dd`, `V`, etc.) don't work very well.

It is also possible to enable the longline mode for certain filetypes
automatically by using an autocommand:

```vim
" Enable the longlines plugin for TeX and MediaWiki files.
augroup longlines
  autocmd!
  autocmd FileType mediawiki,tex LongLinesOn
augroup END
```

License
-------

Public domain. See the file UNLICENSE for more details.
