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
  let g:vimcodeclimate_analyze_cmd = 'codeclimate analyze '
endif

function! s:CodeClimateAnalyzeCurrentFile()
  if &modified
    echohl WarningMsg | echo 'CodeClimate analyzes files on disk: unsaved changes will not be analyzed.' | echohl None
  endif

  echo 'Running codeclimate analyze...'
  let l:filename = @%
  let l:analyze_results = []
  let l:analyze_output = system(g:vimcodeclimate_analyze_cmd.l:filename)
  if v:shell_error
    echohl ErrorMsg | echo 'codeclimate failed: try `codeclimate validate-config` or `codeclimate analyze` in your shell.' |  echohl None
    return
  endif
  for l:line in split(l:analyze_output, "\n")
    if matchstr(l:line, '^\d\+\:')
      call add(l:analyze_results, l:filename.':'.l:line)
    endif
  endfor
  let l:old_errorformat = &errorformat
  set errorformat=%f:%l:%m
  cexpr l:analyze_results
  copen
  call s:CodeClimateBindQuickHelpShortcuts()
  let &errorformat = l:old_errorformat
endfunction

function! s:CodeClimateBindQuickHelpShortcuts()
  " Shortcuts borrowed from vim-rubocop via Ack.vim -
  " git://github.com/ngmy/vim-rubocop.git
  nnoremap <buffer> <silent> ? :call <SID>CodeClimateQuickHelp()<CR>
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

function! s:CodeClimateQuickHelp()
  execute 'edit' globpath(&rtp, 'doc/codeclimate_quick_help.txt')

  silent normal! gg
  setlocal buftype=nofile bufhidden=hide nobuflisted
  setlocal nomodifiable noswapfile
  setlocal filetype=help
  setlocal nonumber norelativenumber nowrap
  setlocal foldmethod=diff foldlevel=20

  nnoremap <silent> <buffer> ? :q!<CR>:copen<CR>:call <SID>CodeClimateBindQuickHelpShortcuts()<CR>
endfunction

command! CodeClimateAnalyzeCurrentFile :call <SID>CodeClimateAnalyzeCurrentFile()

