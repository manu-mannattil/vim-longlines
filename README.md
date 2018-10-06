vim-longlines
=============

A Vim plugin to help navigate through long soft-wrapped lines.

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

License
-------

Public domain. See the file UNLICENSE for more details.
