" Vim indentation file
" Language:     Hack (PHP)
" Maintainer:   Joe Palazzolo <jpalazzolo@fb.com>
" URL:          https://github.com/hhvm/vim-hack
" Last Change:  May 31, 2019
"
" Copyright: (c) 2014, Facebook Inc.  All rights reserved.
"
" This source code is licensed under the MIT license found in the
" LICENSE file in the toplevel directory of this source tree.

if exists("b:indent_loaded")
  finish
end
let b:indent_loaded = 1

setlocal indentexpr=GetHackIndent()

function! GetHackIndent()
  let php_indent = GetPhpIndent()

  if getline(v:lnum-1) =~? '^\s*<<.*>>$'
    return php_indent - shiftwidth()
  end

  return php_indent
endfunction
