" Runs the CodeClimate CLI and display the results in the quickfix window
"
" Author:    Will Fleming
" URL:       https://github.com/wfleming/vim-codeclimate
" Version:   0.1
" Copyright: Copyright (c) 2016 Will Fleming
" License:   MIT
" ----------------------------------------------------------------------------

if exists('g:loaded_vimcodeclimate') || &cp
  finish
endif
let g:loaded_vimcodeclimate = 1

if !exists('g:vimcodeclimate_analyze_cmd')
  let g:vimcodeclimate_analyze_cmd = 'codeclimate analyze'
endif

function! s:AnalyzeProject()
  if s:AnyBufferModified(s:EligibleBuffers())
    call s:ModifiedFilesWarning()
  endif

  call s:RunAnalysis('')
endfunction

function! s:AnalyzeOpenFiles()
  let l:bufs = s:EligibleBuffers()
  if s:AnyBufferModified(l:bufs)
    call s:ModifiedFilesWarning()
  endif

  let l:files = s:BufferNames(l:bufs)

  call s:RunAnalysis(join(map(l:files, 'shellescape(v:val)'), ' '))
endfunction

function! s:AnalyzeCurrentFile()
  if &modified
    call s:ModifiedFilesWarning()
  endif

  call s:RunAnalysis(shellescape(@%))
endfunction

function! s:EligibleBuffers()
  let l:bufs = []
  let l:idx = bufnr('^')
  while l:idx <= bufnr('$')
    if '' ==# getbufvar(l:idx, '&buftype') && filereadable(expand('#'.l:idx.':p'))
      call add(l:bufs, l:idx)
    endif
    let l:idx = l:idx + 1
  endwhile
  return l:bufs
endfunction

function! s:BufferNames(buffers)
  let l:names = []
  let l:cwd = getcwd()
  for l:idx in a:buffers
    let l:fullPath = expand('#'.l:idx.':p')
    if 0 == stridx(l:fullPath, l:cwd)
      let l:relPath = strpart(l:fullPath, strlen(l:cwd) + 1)
      call add(l:names, l:relPath)
    endif
  endfor
  return l:names
endfunction

function! s:AnyBufferModified(buffers)
  for l:idx in a:buffers
    if getbufvar(l:idx, '&mod')
      return 1
    endif
  endfor
  return 0
endfunction

function! s:ModifiedFilesWarning()
  echohl WarningMsg | echo 'CodeClimate analyzes files on disk: unsaved changes will not be analyzed.' | echohl None
endfunction

function! s:RunAnalysis(files)
  echo 'Running codeclimate analyze...'
  let l:analyze_cmd = g:vimcodeclimate_analyze_cmd.' '.a:files
  let l:analyze_output = system(l:analyze_cmd)
  if v:shell_error
    echohl ErrorMsg
    echo 'codeclimate failed: try `codeclimate validate-config` or `codeclimate analyze` in your shell.'
    echo 'failed command: '.l:analyze_cmd
    echohl None
    return
  endif
  let l:issues = s:ParseIssues(l:analyze_output)
  if 0 == len(l:issues)
    echo 'Code Climate found no issues! Well done.'
  else
    call s:ShowIssues(l:issues)
  endif
endfunction

function! s:ParseIssues(text)
  let l:issues = []
  let l:currentFile = ''
  let l:lineNumber = ''
  for l:line in split(a:text, "\n")
    if 0 == stridx(l:line, '== ')
      let l:currentFile = substitute(l:line, '\v^\=\= (.+) \(.+\=\=$', '\1', 'i')
    elseif matchstr(l:line, '\v^\d+(-\d+)?:')
      let l:lineNumber = substitute(l:line, '\v^(\d+)(-\d+)(:.*)', '\1\3', 'g')
      call add(l:issues, l:currentFile.':'.l:lineNumber)
    endif
  endfor
  return l:issues
endfunction

function! s:ShowIssues(issues)
  let l:old_errorformat = &errorformat
  set errorformat=%f:%l:%m
  cexpr a:issues
  copen
  call s:BindQuickShortcuts()
  let &errorformat = l:old_errorformat
endfunction

function! s:BindQuickShortcuts()
  " Shortcuts borrowed from vim-rubocop via Ack.vim -
  " git://github.com/ngmy/vim-rubocop.git
  nnoremap <buffer> <silent> ? :call <SID>QuickHelp()<CR>
  nnoremap <silent> <buffer> q :ccl<CR>
  nnoremap <silent> <buffer> t <C-W><CR><C-W>T
  nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>
  nnoremap <silent> <buffer> o <CR>
  nnoremap <silent> <buffer> go <CR><C-W><C-W>
  nnoremap <silent> <buffer> h <C-W><CR><C-W>K
  nnoremap <silent> <buffer> H <C-W><CR><C-W>K<C-W>b
  nnoremap <silent> <buffer> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t
  nnoremap <silent> <buffer> gv <C-W><CR><C-W>H<C-W>b<C-W>J
endfunction

function! s:QuickHelp()
  execute 'edit' globpath(&rtp, 'doc/codeclimate_quick_help.txt')

  silent normal! gg
  setlocal buftype=nofile bufhidden=hide nobuflisted
  setlocal nomodifiable noswapfile
  setlocal filetype=help
  setlocal nonumber norelativenumber nowrap
  setlocal foldmethod=diff foldlevel=20

  nnoremap <silent> <buffer> ? :q!<CR>:copen<CR>:call <SID>BindQuickShortcuts()<CR>
endfunction

function! codeclimate#sid()
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID>  <SID>

command! CodeClimateAnalyzeProject :call <SID>AnalyzeProject()
command! CodeClimateAnalyzeOpenFiles :call <SID>AnalyzeOpenFiles()
command! CodeClimateAnalyzeCurrentFile :call <SID>AnalyzeCurrentFile()

