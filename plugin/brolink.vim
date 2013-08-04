" File:        brolink.vim
" Version:     2.0.0
" Description: Links VIM to your browser for live/responsive editing.
" Maintainer:  Jonathan Warner <jaxbot@gmail.com> <http://github.com/jaxbot>
" Homepage:    http://jaxbot.me/
" Repository:  https://github.com/jaxbot/brolink.vim 
" License:     Copyright (C) 2013 Jonathan Warner
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

python <<NOMAS
import sys
import threading
import time
import vim
sys.path.append(vim.eval("expand('<sfile>:p:h')") + "/websocket_client-0.11.0-py2.7.egg")
import websocket

class BrolinkLink(threading.Thread):

	def __init__ (self, ws):
		threading.Thread.__init__(self)
		self.ws = ws
	
	def run(self):
		def on_message(ws, message):
			vim.command("echo '" + message + "'")
		def on_close(ws):
			if (can_close == 0):
				ws.run_forever()
	  
		#ws.on_message = on_message
		ws.on_close = on_close
		ws.run_forever()

can_close = 0

ws = websocket.WebSocketApp("ws://127.0.0.1:9001/")

thread = BrolinkLink(ws)

def disconnect():
	can_close = 1
	ws.close()

def startbrolink():
	thread.start()
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
	python ws.send(vim.eval("a:js"))
endfunction

function! s:ReloadTemplate()
	python ws.send("___RTEMPLATE")
endfunction

function! s:ReloadPage()
	python ws.send("___RPAGE")
endfunction

function! s:ReloadCSS()
	python ws.send("___RCSS")
endfunction

function! s:Disconnect()
	python disconnect()
endfunction

function! s:Connect()
	python startbrolink()
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
    "au BufWritePost templates/*.html :BLReloadTemplate
    au BufWritePost *.css :BLReloadCSS	
endfunction

command! -range -nargs=0 BLEvaluateSelection call s:EvaluateSelection()
command!        -nargs=0 BLEvaluateBuffer    call s:EvaluateBuffer()
command!        -nargs=0 BLEvaluateWord      call s:EvaluateWord()
command!        -nargs=1 BLEval              call s:evaluateJS(<f-args>)
command!        -nargs=0 BLReloadPage        call s:ReloadPage()
command!        -nargs=0 BLReloadTemplate    call s:ReloadTemplate()
command!        -nargs=0 BLReloadCSS         call s:ReloadCSS()
command!        -nargs=0 BLDisconnect        call s:Disconnect()
command!        -nargs=0 BLStart             call s:Start()

if !exists("g:bl_no_mappings")
    vmap <silent><Leader>be :BLEvaluateSelection<CR>
    nmap <silent><Leader>be :BLEvaluateBuffer<CR>
    nmap <silent><Leader>bf :BLEvaluateWord<CR>
    nmap <silent><Leader>br :BLReloadPage<CR>
    nmap <silent><Leader>bc :BLReloadCSS<CR>
endif

function! s:Start()
	if !exists("g:bl_no_autoupdate")
		call s:setupHandlers()
	endif
	call s:Connect()
endfunction

if !exists("g:bl_no_implystart")
	call s:Start()
endif

au VimLeave * :BLDisconnect
