source plugin/codeclimate.vim
call vspec#hint({'sid': 'codeclimate#sid()'})

describe "codeclimate#ParseIssues"
  it "handles single and multiline issues"
    let l:ccOutput = "== file.sh (13 issues) ==\n59: issue desc a [engine]\n10-20: issue desc b [engine]\n"
    let l:parsedIssues = Call("s:ParseIssues", l:ccOutput)
    let l:expectedIssues = ["file.sh:59: issue desc a [engine]", "file.sh:10: issue desc b [engine]"]
    Expect l:parsedIssues == l:expectedIssues
  end

  it "handles multiple files"
    let l:ccOutput = "== file.sh (13 issues) ==\n59: issue desc a [engine]\n\n== other.rb (1 issue) ==\n10-20: issue desc b [wtf]\n"
    let l:parsedIssues = Call("s:ParseIssues", l:ccOutput)
    let l:expectedIssues = ["file.sh:59: issue desc a [engine]", "other.rb:10: issue desc b [wtf]"]
    Expect l:parsedIssues == l:expectedIssues
  end
end

function! MockRunAnalysis()
  let s = 'function! ' . codeclimate#sid() . 'RunAnalysis(args)' . "\n"
  let s = s . '  let g:t_runopts = a:args' . "\n"
  let s = s . 'endfunction'
  execute s
  let g:t_runopts = "not-called"
endfunction

function! EscapePath(path)
  " This is pretty wacky, and I'm not sure why the strings get so mangled.  CLI
  " invocations seem fine when actually used & echoed for debugging, so I think
  " this is some weird vspec mangling, and this escaping works around it.
  " ¯\_(ツ)_/¯
  return '''''\''''' . a:path . '''\'''''''
endfunction

describe "buffer opts"
  before
    call MockRunAnalysis()
  end

  describe "CodeClimateAnalyzeCurrentFile"
    it "handles no buffer var set"
      silent edit 'fixtures/foo.rb'
      call Call('s:AnalyzeCurrentFile')
      let l:expected = ' ' . EscapePath('fixtures/foo.rb')
      Expect g:t_runopts ==# l:expected
    end

    it "handles buffer var"
      silent edit 'fixtures/foo.rb'
      let b:codeclimateflags = '--engine rubocop'
      call Call('s:AnalyzeCurrentFile')
      let l:expected = '--engine rubocop ' . EscapePath('fixtures/foo.rb')
      Expect g:t_runopts ==# l:expected
    end
  end
end
