Installation
============

The preferred method of installation is using [Pathogen][pathogen].  Then
simply run

    cd ~/.vim/bundle
    git clone git://github.com/hhvm/vim-hack.git

The Hack syntax file assumes that you are using the default PHP syntax file
that ships with Vim 7.4, or a compatible file.

Put `let g:hack#enable = 0` in your .vimrc if you want to disable typechecker but keep indenting.

For more information on the Hack language, visit http://hacklang.org.

[pathogen]: https://github.com/tpope/vim-pathogen
