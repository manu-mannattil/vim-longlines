vim-longlines
=============

A Vim plugin to help navigate through long soft-wrapped lines.

Installation
------------

Use your favorite plugin manager or install as a Vim package (see `:help
packages`).

Usage
-----

After installing the plugin, use `:LongLines` to toggle the longline
mode and `:LongLines!` to turn it off.  It's also possible to
automatically enable the longline mode for certain filetypes by using an
autocommand:

```vim
" Enable the longlines plugin for TeX and MediaWiki files.
autocmd FileType mediawiki,tex LongLines
```

When the longline mode is on, motion commands such as `j`, `k`, `gg`,
`G`, etc., work on display lines rather than actual lines.  Although the
longline mode replicates most commands reasonably well, some mappings
(e.g., `dd`, `V`, etc.) don't work very well, and scrolling moves the
cursor.

### Options

When the longline mode is on, text is not hardwrapped by default and
options that enable automatic hardwrapping of text (e.g., Vim's default
`fo=tcq`) are altered to prevent this.  If you wish to keep these
options unaltered, set the global variable `g:longlines_keep_opts` or
the buffer variable `b:longlines_keep_opts` to a nonzero value:

```Vim
let g:longlines_keep_opts = 1
```

Similarly, when the longline mode is on, all motions commands are
remapped to work on display lines, even when user-defined maps exist.
If you wish to preserve already existing mappings, set the global
variable `g:longlines_keep_maps` or the buffer variable
`b:longlines_keep_maps` to a nonzero value:

License
-------

Public domain. See the file UNLICENSE for more details.
