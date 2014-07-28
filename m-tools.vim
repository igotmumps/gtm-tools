function! Zdump(gbl)
	let l:gbl=a:gbl
	let $gtmroutines=$HOME . "/gtm/o(" . $HOME . "/gtm/r) " . $gtmroutines
	let l:gbl = system("mumps -r KBAWDUMP '" . l:gbl . "'")

	if l:gbl=~ "%GTM-E-FILENOTFND"
		echol ErrorMsg
		echom "%GTM-E-FILENOTFND: Can't locate ZDUMP^MTOOLS in $ZRO"
		echol None
	elseif l:gbl =~ "command not found"
		echohl ErrorMsg
		echo "mumps: command not found: Install MUMPS on your system"
		echohl None
	else
		"call setline(line('.'), getline('.') . ' ' . l:rv)
		echo l:gbl
		let @g=l:gbl
    endif
endfunction

command! -nargs=1 ZDMP call Zdump(<q-args>) 

function! ZTarget(env)
	let l:env=a:env
	let l:rv = system("env")
	let l:rv = system(".gtmenv")
endfunction

" Comment wrap
let g:wrap_char = ';'
function! Comment() range
    let lines = getline(a:firstline,a:lastline)
    for i in range(len(lines))
        let ll = len(lines[i])
        let lines[i] = "\t" . g:wrap_char . ' ' . split(lines[i],"\t")[0] 
    endfor  
    let result = []
    call extend(result, lines)
    execute a:firstline.','.a:lastline . ' d'
    let s = a:firstline-1<0?0:a:firstline-1
    call append(s, result)
endfunction


nnoremap <silent> <Leader>c :call Comment()<CR> 
