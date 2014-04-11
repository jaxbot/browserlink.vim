" File:        brolink.vim
" Version:     2.5.0
" Description: Links VIM to your browser for live/responsive editing.
" Maintainer:  Jonathan Warner <jaxbot@gmail.com> <http://github.com/jaxbot>
" Homepage:    http://jaxbot.me/
" Repository:  https://github.com/jaxbot/brolink.vim 
" License:     Copyright (C) 2014 Jonathan Warner
"              Released under the MIT license 
"			   ======================================================================
"              

if exists("g:bl_loaded") || &cp
    finish
endif
let g:bl_loaded = "si"

if !exists("g:bl_serverpath") 
	let g:bl_serverpath = "http://127.0.0.1:9001"
endif

let g:bl_state = 0

python <<NOMAS
import sys
import time
import urllib2
import vim
NOMAS

function! s:EvaluateSelection()
	call s:evaluateJS(s:get_visual_selection()) 
endfunction

function! s:EvaluateBuffer()
	call s:evaluateJS(join(getline(1,'$')," "))
endfunction

function! s:EvaluateWord()
	call s:evaluateJS(expand("<cword>") . "()")
endfunction

function! s:evaluateJS(js) 
	python urllib2.urlopen(urllib2.Request(vim.eval("g:bl_serverpath") + "/evaluateJS", vim.eval("a:js")))
endfunction

function! s:sendCommand(command)
	python urllib2.urlopen(vim.eval("g:bl_serverpath") + "/" + vim.eval("a:command"))
endfunction

function! s:get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - 2]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, " ")
endfunction

function! s:setupHandlers() 
    au BufWritePost *.html,*.js,*.php :BLReloadPage
    au BufWritePost *.css :BLReloadCSS	
endfunction

command! -range -nargs=0 BLEvaluateSelection call s:EvaluateSelection()
command!        -nargs=0 BLEvaluateBuffer    call s:EvaluateBuffer()
command!        -nargs=0 BLEvaluateWord      call s:EvaluateWord()
command!        -nargs=1 BLEval              call s:evaluateJS(<f-args>)
command!        -nargs=0 BLReloadPage        call s:sendCommand("reloadPage")
command!        -nargs=0 BLReloadCSS         call s:sendCommand("reloadCSS")

if !exists("g:bl_no_mappings")
    vmap <silent><Leader>be :BLEvaluateSelection<CR>
    nmap <silent><Leader>be :BLEvaluateBuffer<CR>
    nmap <silent><Leader>bf :BLEvaluateWord<CR>
    nmap <silent><Leader>br :BLReloadPage<CR>
    nmap <silent><Leader>bc :BLReloadCSS<CR>
endif

if !exists("g:bl_no_autoupdate")
	call s:setupHandlers()
endif

