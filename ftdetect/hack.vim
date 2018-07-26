" Vim ftdetect file
" Language:     Hack (PHP)
" Maintainer:   Max Wang <mwang@fb.com>
" URL:          https://github.com/hhvm/vim-hack
" Last Change:  April 3, 2014
"
" Copyright: (c) 2014, Facebook Inc.  All rights reserved.
"
" This source code is licensed under the BSD-style license found in the
" LICENSE file in the toplevel directory of this source tree.  An additional
" grant of patent rights can be found in the PATENTS file in the same
" directory.

au BufRead,BufNewFile *.hhi
  \ setl filetype=hack |
  \ runtime! syntax/php.vim

au BufRead,BufNewFile *.hh,*.php
  \ if getline(1) =~ '^<?hh' |
  \   setl filetype=hack |
  \   runtime! syntax/php.vim |
  \ endif
