" File:        browserlink.vim
" Version:     2.6.0
" Description: Links VIM to your browser for live/responsive editing.
" Maintainer:  Jonathan Warner <jaxbot@gmail.com> <http://github.com/jaxbot>
" Homepage:    http://jaxbot.me/
" Repository:  https://github.com/jaxbot/browserlink.vim
" License:     Copyright (C) 2014 Jonathan Warner
"              Released under the MIT license
"			   ======================================================================
"

if !exists("g:bl_serverpath")
	let g:bl_serverpath = "http://127.0.0.1:9001"
endif

if !exists("g:bl_pagefiletypes")
	let g:bl_pagefiletypes = ["html", "javascript", "php"]
endif

let g:bl_state = 0

command! -range -nargs=0 BLEvaluateSelection call browserlink#EvaluateSelection()
command!        -nargs=0 BLEvaluateBuffer    call browserlink#EvaluateBuffer()
command!        -nargs=0 BLEvaluateWord      call browserlink#EvaluateWord()
command!        -nargs=1 BLEval              call browserlink#evaluateJS(<f-args>)
command!        -nargs=0 BLReloadPage        call browserlink#sendCommand("reload/page")
command!        -nargs=0 BLReloadCSS         call browserlink#sendCommand("reload/css")
command!        -nargs=0 BLConsoleClear      call browserlink#sendCommand("clear")
command!        -nargs=0 BLConsole           edit browserlink/console
command!        -nargs=0 BLErrors            call browserlink#getErrors()
command!        -nargs=0 BLClearErrors       call browserlink#clearErrors()
command!        -nargs=0 BLTraceLine         call browserlink#traceLine()
autocmd BufReadCmd browserlink/console* call browserlink#getConsole()

if !exists("g:bl_no_mappings")
	vmap <silent><Leader>be :BLEvaluateSelection<CR>
	nmap <silent><Leader>be :BLEvaluateBuffer<CR>
	nmap <silent><Leader>bf :BLEvaluateWord<CR>
	nmap <silent><Leader>br :BLReloadPage<CR>
	nmap <silent><Leader>bc :BLReloadCSS<CR>
endif

function! s:autoReload()
	if index(g:bl_pagefiletypes, &ft) >= 0
		call browserlink#sendCommand("reload/page")
	endif
endfunction

function! s:setupHandlers()
	au BufWritePost * call s:autoReload()
	au BufWritePost *.css :BLReloadCSS
endfunction

if !exists("g:bl_no_autoupdate")
	call s:setupHandlers()
endif

if !exists("g:bl_no_eager")
	let g:bl_no_eager = 0
endif

