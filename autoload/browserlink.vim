let s:path = expand('<sfile>:p:h:h')

python <<NOMAS
import sys
import time
import urllib2
import vim
import os
import subprocess
NOMAS

function! browserlink#EvaluateSelection()
	call browserlink#evaluateJS(browserlink#get_visual_selection())
endfunction

function! browserlink#EvaluateBuffer()
	call browserlink#evaluateJS(join(getline(1,'$')," "))
endfunction

function! browserlink#EvaluateWord()
	call browserlink#evaluateJS(expand("<cword>") . "()")
endfunction

function! browserlink#evaluateJS(js)
	python urllib2.urlopen(urllib2.Request(vim.eval("g:bl_serverpath") + "/evaluate", vim.eval("a:js")))
endfunction

function! browserlink#sendCommand(command)
	python <<EOF
try:
	urllib2.urlopen(vim.eval("g:bl_serverpath") + "/" + vim.eval("a:command")).read()
except:
	vim.command("call browserlink#startBrowserlink()")
EOF
endfunction

function! browserlink#startBrowserlink()
	if has("win32")
		execute 'cd' fnameescape(s:path . "/browserlink")
		call system("./start.bat")
		execute 'cd -'
	else
		execute 'cd' fnameescape(s:path . "/browserlink")
		call system("node browserlink.js &")
		execute 'cd -'
	endif
endfunction

function! browserlink#getConsole()
	normal ggdG
python <<EOF
data = urllib2.urlopen(vim.eval("g:bl_serverpath") + "/console").read()
for line in data.split("\n"):
	vim.current.buffer.append(line)
EOF
	setlocal nomodified
	nnoremap <buffer> i :BLEval
	nnoremap <buffer> cc :BLConsoleClear<cr>:e<cr>
	nnoremap <buffer> r :e!<cr>
	nnoremap <buffer> <cr> :BLTraceLine<cr>
endfunction

function! browserlink#url2path(url)
	let path = a:url
	" strip off any fragment identifiers
	let hashIdx = stridx(a:url, '#')
	if hashIdx > -1
		let path = strpart(path, 0, hashIdx)
	endif
	" translate file-URLs
	if stridx(path,'file://') == 0
		return strpart(path,7)
	endif
	" for everything else, look up user-defined mappings
	if exists("g:bl_urlpaths")
		for key in keys(g:bl_urlpaths)
			if stridx(path, key) == 0
				return g:bl_urlpaths[key] . strpart(path, strlen(key))
			endif
		endfor
	endif
	return path
endfunction

function! browserlink#getErrors()
python <<EOF
data = urllib2.urlopen(vim.eval("g:bl_serverpath") + "/errors").readlines()
vim.command("let errors = %s" % [e.strip() for e in data])
EOF
	set errorformat+=%f:%l:%m
	let qfitems = []
	for errorstr in errors
		let error = eval(errorstr)
		let msg = error.message
		if error.multiplicity > 1
			let msg = msg . ' (' . error.multiplicity . ' times)'
		endif
		let qfitems = qfitems + [browserlink#url2path(error.url) . ':' . error.lineNumber . ':' . msg]
	endfor
	cexpr join(qfitems, "\n")
endfunction

function! browserlink#clearErrors()
python <<EOF
urllib2.urlopen(vim.eval("g:bl_serverpath") + "/clearerrors")
EOF
endfunction

function! browserlink#traceLine()
python <<EOF

line = vim.eval("getline('.')")
fragments = line.split('/')
page = fragments[-1].split(':')[0]
line = fragments[-1].split(':')[1]

vim.command("b " + page)
vim.command(":" + line)
EOF
endfunction

function! browserlink#get_visual_selection()
	let [lnum1, col1] = getpos("'<")[1:2]
	let [lnum2, col2] = getpos("'>")[1:2]
	let lines = getline(lnum1, lnum2)
	let lines[-1] = lines[-1][: col2 - 2]
	let lines[0] = lines[0][col1 - 1:]
	return join(lines, " ")
endfunction
