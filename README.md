About `vim-hack`
================

`vim-hack` provides file type detection and syntax highlighting for Hack files.

For advanced features, we recommend using this plugin in combination with a
Language Server Protocol plugin for Vim, such as
[LanguageClient-neovim], configured to run `hh_client lsp` for `hack` files - for example:

```
let g:LanguageClient_serverCommands = {
  \ 'hack': [ 'hh_client', 'lsp' ],
  \ }
```

LanguageClient-neovim supports both vim and nevim.

Installation
============

The preferred method of installation is using [Pathogen][pathogen].  Then
simply run

    cd ~/.vim/bundle
    git clone https://github.com/hhvm/vim-hack.git

The Hack syntax file assumes that you are using the default PHP syntax file
that ships with Vim 7.4, or a compatible file.

For more information on the Hack language, visit http://hacklang.org.

License
=======

vim-hack is BSD licensed, as found in the LICENSE file. We also provide an
additional patent grant.

[pathogen]: https://github.com/tpope/vim-pathogen
[LanguageClient-neovim]: https://github.com/autozimu/LanguageClient-neovim
