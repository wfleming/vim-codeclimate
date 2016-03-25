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
