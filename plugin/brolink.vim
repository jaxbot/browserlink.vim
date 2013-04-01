" File:        brolink.vim
" Version:     1.0.0
" Description: Links VIM to your browser for live/responsive editing.
" Maintainer:  Jonathan Warner <jaxbot@gmail.com> <http://github.com/jaxbot>
" Homepage:    http://societyofcode.com/
" Repository:  https://github.com/jaxbot/brolink.vim 
" License:     Copyright (C) 2013 Jonathan Warner
"
"			   DO WHAT THE F*CK YOU WANT TO PUBLIC LICENSE
"              Everyone is permitted to copy and distribute verbatim or modified
"			   copies of this license document, and changing it is allowed as long
"			   as the name is changed.
"
"	           DO WHAT THE F*CK YOU WANT TO PUBLIC LICENSE
"			   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
"			   0. You just DO WHAT THE F*CK YOU WANT TO.
"			   ======================================================================
"              

if exists("g:bl_loaded") || &cp
    finish
endif
let g:bl_loaded = "si"

if !exists("g:bl_serverpath") 
	let g:bl_serverpath = "http://127.0.0.1:9001"
endif

function! s:EvaluateSelection()
	call s:evaluateJS(s:get_visual_selection()) 
endfunction

function! s:EvaluateBuffer()
	call s:evaluateJS(join(getline(1,'$')," "))
endfunction

function! s:evaluateJS(js) 
	call system("curl --max-time 1 --data \"" . escape(a:js,"\"") . "\" " . g:bl_serverpath . "/evaluateJS")
endfunction

function! s:ReloadPage()
	call system("curl --max-time 1 " . g:bl_serverpath . "/reloadPage")
endfunction

function! s:ReloadCSS()
	call system("curl --max-time 1 " . g:bl_serverpath . "/reloadCSS")
endfunction

function! s:get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - 2]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, " ")
endfunction

command! -range -nargs=0 BLEvaluateSelection call s:EvaluateSelection()
command!        -nargs=0 BLEvaluateBuffer    call s:EvaluateBuffer()
command!        -nargs=0 BLReloadPage        call s:ReloadPage()
command!        -nargs=0 BLReloadCSS         call s:ReloadCSS()

if !exists("g:bl_no_mappings")
    vmap <silent><Leader>be :BLEvaluateSelection<CR>
    nmap <silent><Leader>be :BLEvaluateBuffer<CR>
    nmap <silent><Leader>br :BLReloadPage<CR>
    nmap <silent><Leader>bc :BLReloadCSS<CR>
endif

if !exists("g:bl_no_autoupdate")
    au BufWritePost *.html,*.js,*.php :BLReloadPage
    au BufWritePost *.css :BLReloadCSS	
endif

