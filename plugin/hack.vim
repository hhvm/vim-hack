" hack.vim - Hack typechecker integration for vim
" Language:     Hack (PHP)
" Maintainer:   Srećko Toroman <storoman@fb.com>
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

if exists("g:loaded_hack")
  finish
endif
let g:loaded_hack = 1

if !exists('g:hack#edit_mode')
  let g:hack#edit_mode = 'edit'
endif

if !exists('g:hack#hh_client')
  let g:hack#hh_client = 'hh_client'
endif

" Require the hh_client executable.
if !executable(g:hack#hh_client)
  finish
endif

" Configuration switches:
" - enable:     Typechecking is done on :w.
" - autoclose:  Quickfix window closes automatically.
" - errjmp:     Jump to errors after typechecking; default off.
" - qfsize:     Let the plugin control the quickfix window size.
if !exists("g:hack#enable")
  let g:hack#enable = 1
endif
if !exists("g:hack#autoclose")
  let g:hack#autoclose = 1
endif
if !exists("g:hack#errjmp")
  let g:hack#errjmp = 0
endif
if !exists("g:hack#qfsize")
  let g:hack#qfsize = 1
endif

let s:nvim = has('nvim') && exists('*jobwait')

" hh_client error format.
let s:hack_errorformat =
  \  '%EFile "%f"\, line %l\, characters %c-%.%#,%Z%m,'
  \ .'Error: %m,'

function! s:JobStdoutHandler(job_id, data, event)
  let s:stdout = s:stdout + a:data
endfunction

function! s:JobExitHandler(job_id, data, event)
  let hh_result = join(s:stdout, "\n")
  call <SID>HackPopulateQuickfix(hh_result)
endfunction

" Returns command line for calling hack.
function! <SID>HackClientInvocation(extra_args)
  return [
  \ g:hack#hh_client,
  \ '--from', 'vim',
  \ '--retries', '1',
  \ '--retry-if-init', 'false'
  \ ] + a:extra_args
endfunction

" Call wrapper for hh_client.
function! <SID>HackClientCall(extra_args)
  " Invoke typechecker. If using neovim, then invoke it asynchronously with
  " Neovim's job-control functionality.
  let hh_command = <SID>HackClientInvocation(a:extra_args)

  if s:nvim
    let s:stdout = []
    let callbacks = {
    \ 'on_stdout': function('s:JobStdoutHandler'),
    \ 'on_exit': function('s:JobExitHandler')
    \ }
    return jobstart(hh_command, callbacks)
  endif

  " We strip the trailing newline to avoid an empty error. We also concatenate
  " with the empty string because otherwise cgetexpr complains about not
  " having a String argument, even though type(hh_result) == 1.
  let hh_result = system(join(hh_command))[:-2].''
  call <SID>HackPopulateQuickfix(hh_result)
endfunction

function! <SID>HackPopulateQuickfix(hh_result)
  let old_fmt = &errorformat
  let &errorformat = s:hack_errorformat

  if g:hack#errjmp
    cexpr a:hh_result
  else
    cgetexpr a:hh_result
  endif

  let l:winnr = winnr()
  if g:hack#autoclose
    botright cwindow
  else
    botright copen
  endif

  if (s:nvim && l:winnr != winnr())
    exe l:winnr . "wincmd w"
  endif

  let &errorformat = old_fmt
endfunction

" Lookup the identifier under cursor.
function! <SID>HackLookupCurrentIdentifier()
  silent let result = system(
  \ join(<SID>HackClientInvocation(['--identify-function', line('.').':'.col('.')])),
  \ getline(1, '$'))
  return substitute(result, '^\s*\(.\{-}\)\s*$', '\1', '') " strip ws
endfunction

" Main interface functions.
function! hack#typecheck()
  call <SID>HackClientCall([])
endfunction

function! hack#find_refs(fn)
  call <SID>HackClientCall(['--find-refs', a:fn])
endfunction

function! hack#search(full_lookup, name)
  let name = a:name
  if name == ''
    " Look up full identifier.
    if a:full_lookup
      let name = <SID>HackLookupCurrentIdentifier()
    endif
    " Use current word.
    if name == ''
      let name = substitute(expand('<cword>'), '[^A-Za-z0-9_$].*$', '', '')
    endif
  end
  call <SID>HackClientCall(['--search', name])
endfunction

" Get the Hack type at the current cursor position.
function! hack#get_type()
  let pos = line('.').':'.col('.')
  let cmd = join(<SID>HackClientInvocation(['--type-at-pos', pos]))
  let stdin = join(getline(1,'$'), "\n")

  let output = 'HackType: '.system(cmd, stdin)
  let output = substitute(output, '\n$', '', '')
  echo output
endfunction

" Go to the definition of the expression at the current cursor position.
function! hack#goto_def()
  if !has('nvim') && v:version < 800
    echom 'Vim 8.0 or Neovim is required for this function.'
    return
  endif

  let pos = line('.').':'.col('.')
  let cmd = join(<SID>HackClientInvocation([
  \ '--json',
  \ '--ide-get-definition',
  \ pos
  \ ]))
  let stdin = join(getline(1,'$'), "\n")

  let output = get(json_decode(system(cmd, stdin)), 0, {})
  if !has_key(output, 'definition_pos')
    return
  endif

  let pos = output.definition_pos
  if !empty(pos.filename)
    execute g:hack#edit_mode . ' ' . (pos.filename)
  endif
  call cursor(pos.line, pos.char_start)
endfunction

" Toggle auto-typecheck.
function! hack#toggle()
  if g:hack#enable
    let g:hack#enable = 0
  else
    let g:hack#enable = 1
  endif
endfunction

function! hack#format(from, to)
  if !executable(g:hack#hh_format)
    echo 'g:hack#hh_format not executable'
  endif

  if &modified
    echo 'Error[hack]: buffer has unsaved changes'
    return
  endif

  let frombyte = line2byte(a:from)
  let tobyte = line2byte(a:to) + strlen(getline(a:to))

  execute a:from.','.a:to.' ! '.g:hack#hh_format.
    \ ' --from '.frombyte.' --to '.tobyte.
    \ ' --root '.g:hack#root.' '.expand('%:p')
  let tmp = g:hack#enable
  " Disable auto checking
  let g:hack#enable = 0
  silent write
  let g:hack#enable = tmp
endfunction

" Commands and auto-typecheck.
command! HackToggle call hack#toggle()
command! HackMake   call hack#typecheck()
command! HackType   call hack#get_type()
command! HackGotoDef call hack#goto_def()
command! -range=% HackFormat call hack#format(<line1>, <line2>)
command! -nargs=1 HackFindRefs call hack#find_refs(<q-args>)
command! -nargs=? -bang HackSearch call hack#search('<bang>' == '!', <q-args>)

au BufWritePost *.php if g:hack#enable | call hack#typecheck() | endif
au BufWritePost *.hhi if g:hack#enable | call hack#typecheck() | endif
au BufWritePost *.hh if g:hack#enable | call hack#typecheck() | endif


" Keep quickfix window at an adjusted height.
function! <SID>AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

au FileType qf if g:hack#qfsize | call <SID>AdjustWindowHeight(3, 10) | endif
