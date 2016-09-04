function! AsciidocFolds()
  let depth = HeadingDepth(v:lnum)
  if depth > 0
    return ">".depth
  else
    return "="
  endif
endfunction

function! HeadingDepth(lnum)
  let level = -1
  let thisline = getline(a:lnum)
  if thisline !~ '\(^[[. \t]\)\|\(^\s*$\)'
    let nextline = getline(a:lnum + 1)
    if nextline =~ '^===\+\s*$'
      let level = 0
    elseif nextline =~ '^---\+\s*$'
      let level = 1
    elseif nextline =~ '^\~\~\~\+\s*$'
      let level = 2
    elseif nextline =~ '^\^\^\^\+\s*$'
      let level = 3
    elseif nextline =~ '^+++\+\s*$'
      let level = 4
    endif
    if level >= 0
      let title_len = len(matchstr(thisline, '^[^ \t].*[^ \t]'))
      let underline_len = len(matchstr(nextline, '^[^ \t]*'))
      if title_len != underline_len
        let level = -1
      endif
    elseif thisline !~ '^=\+\s*$'
      let hashCount = len(matchstr(thisline, '^=\{1,5}'))
      if hashCount > 0
        let level = hashCount - 1
      endif
    endif
  endif
  if level >= 0 && LineIsFenced(a:lnum)
    " Ignore section headings that are commented out
    let level = -1
  endif
  return level + 1
endfunction

function! LineIsFenced(lnum)
  if exists("b:current_syntax") && b:current_syntax ==# 'asciidoc'
    return s:HasSyntaxGroup(a:lnum, 'asciidocCommentBlock') ||
           \ s:HasSyntaxGroup(a:lnum, 'asciidocListingBlock') ||
           \ s:HasSyntaxGroup(a:lnum, 'asciidocExampleBlock') ||
           \ s:HasSyntaxGroup(a:lnum, 'asciidocPassthroughBlock')
  endif
endfunction

function! s:HasSyntaxGroup(lnum, targetGroup)
  let syntaxGroup = map(synstack(a:lnum, 1), 'synIDattr(v:val, "name")')
  for value in syntaxGroup
    if value == a:targetGroup
      return 1
    endif
  endfor
endfunction

setlocal foldmethod=expr
setlocal foldexpr=AsciidocFolds()

function! AsciidocFoldText()
  let foldsize = (v:foldend - v:foldstart)
  return getline(v:foldstart).' ('.foldsize.' lines)'
endfunction
setlocal foldtext=AsciidocFoldText()

" vim:set fdm=marker:
