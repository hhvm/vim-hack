About `vim-hack`
================

`vim-hack` provides file type detection and syntax highlighting for Hack files.

The Hack syntax file assumes that you are using the default PHP syntax file
that ships with Vim 7.4, or a compatible file.

For more information on the Hack language, visit http://hacklang.org.

Installation
============

Vim 8 and NeoVim
----------------

We recommend installing both this plugin and [ALE] via your favorite plugin manager. ALE provides linting for various languages, and
IDE-like features. If you do not have a plugin manager:

```
$ cd .vim # for Vim8
$ cd .config/neovim # for NeoVim
$ mkdir -p pack/github/start
$ cd pack/github/start
$ git clone https://github.com/hhvm/vim-hack.git
$ git clone https://github.com/w0rp/ale.git
```

By default, ALE will report errors; for additional features, see `:help ale`, or use the configuration below as a starting point:

```
" Automatic completion
let g:ale_completion_enabled = 1
let g:ale_echo_msg_format = '[%linter%]% [code]% %s'
" Enable HHAST - this has security implications (see below)
let g:ale_linters = { 'hack': ['hack', 'hhast'] }
" Press `K` to view the type in the gutter
nnoremap <silent> K :ALEHover<CR>
" Type `gd` to go to definition
nnoremap <silent> gd :ALEGoToDefinition<CR>
" Meta-click (command-click) to go to definition
nnoremap <M-LeftMouse> <LeftMouse>:ALEGoToDefinition<CR>

" show type on hover in a floating bubble
if v:version >= 801
  set balloonevalterm
  let g:ale_set_balloons = 1
  let balloondelay = 250
endif
```

[HHAST] provides additional linting for Hack files - however, it is disabled by default, as it executes code in the project - if `.hhconfig`, `hhast-lint.json`, and `vendor/bin/hhast-lint` exist relative to any ancestor directory, `vendor/bin/hhast-lint` will be executed.

Vim 7
-----

If you want IDE-like features (autocomplete, go to definition, etc), upgrade to Vim 8 or Neovim, and follow the instructions in the previous section.

The preferred method of installation for Vim 7 is using [vim-plug]; after installing vim-plug, put the following in your `.vimrc`:

```
call plug#begin('~/.vim/plugged')
Plug 'hhvm/vim-hack'
call plug#end()
```

Then, run `:PlugInstall` in vim. For advanced features, we *strongly* recommend upgrading to Vim8 or Neovim and using [ALE]; if this isn't possible,
[LanguageClient-neovim] is an alternative:

```
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
```

This can then be enabled with:

```
let g:LanguageClient_serverCommands = {
  \ 'hack': [ 'hh_client', 'lsp' ],
  \ }
```

For a basic configuration, add:

```
" Press `K` to view the type in the gutter
nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
" Type `gd` to go to definition
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
" Meta-click (command-click) to go to definition
nnoremap <M-LeftMouse> <LeftMouse>:call LanguageClient_textDocument_definition()<CR>
```

This binds `K` to 'show type in the gutter', and both `gd` and meta-click ('command-click') to 'go to definition'.

License
=======

vim-hack is BSD licensed, as found in the LICENSE file. We also provide an
additional patent grant.

[ALE]: https://github.com/w0rp/ale
[HHAST]: https://github.com/hhvm/hhast
[LanguageClient-neovim]: https://github.com/autozimu/LanguageClient-neovim
[vim-plug]: https://github.com/junegunn/vim-plug
