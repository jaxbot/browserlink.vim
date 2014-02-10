# Brolink.vim
Brolink is a live browser editing plugin for Vim. 
<img src='https://raw.github.com/jaxbot/brolink.vim/master/brolinkhtml.gif'>

## Live edit CSS

Brolink allows you to live edit CSS files, which are sent to the browser on change, without reloading or changing the state of the page.

<img src='https://raw.github.com/jaxbot/brolink.vim/master/brolinkcss.gif'>

## Live evaluate JavaScript

Brolink allows you to evaluate buffers or selections of JavaScript directly, or even call individual functions within the buffer, for instant feedback in the browser.

<img src='https://raw.github.com/jaxbot/brolink.vim/master/brolinkjs.gif'>

## How it works
Brolink is very simple. The plugin itself hooks autocommands for file changes (and other things) to the provided functions. The functions connect through websockets to a node.js backend, which your webpage connects also to. The entire process happens extremely fast.

Video of version 1.0: http://www.youtube.com/watch?v=w4_fkpVQbAQ (old, and much slower than current version)

## Installation and Setup
To install, either download the repo, or as I would recommend, use [Pathogen](https://github.com/tpope/vim-pathogen).

	git clone git://github.com/jaxbot/brolink.vim.git

Once installed, make sure you have Node installed, and run the server program like so:

	node brolink.js

Feel free to move (or symlink) the brolink server to a more convenient location.

Once Brolink is running in a console, you need to include a reference to it in your web project.
Two options:

1. Add this to your page(s)
	
	<script src='http://127.0.0.1:9001/socket.js'></script>

2. **OR** Use GreaseMonkey or Tampermonkey to automatically embed in your local projects, e.g.


		// ==UserScript==
		// @name       Brolink Embed
		// @namespace  http://use.i.E.your.homepage/
		// @version    0.1
		// @description  enter something useful
		// @match      http://localhost/*
		// @copyright  2012+, You
		// ==/UserScript==
		
		var src = document.createElement("script");
		src.src = "http://127.0.0.1:9001/socket.js";
		src.async = true;
		document.head.appendChild(src);


I prefer the latter, as it's more universal and I don't have extra development junk in my projects. But it's totally up to you.

## Usage

Once set up, Vim should now call the Node server whenever you save a .html, .js, .php, or .css file. Then just load up your web project like normal, and Vim should send signals over the websocket to reload the pages automatically. Nifty.

In addition:

	BLReloadPage

will reload the current pages

	BLReloadCSS

will reload the current stylesheets 

	BLEvaluateBuffer

will evaluate the current buffer

You can also use <leader>be to evaluate selections or buffers, <leader>br to reload, and <leader>bc to reload stylesheets manually.

If you want to get super efficient, you can hook an autocmd to when you leave insert mode (or other times) to reload, say, the stylesheets:

	au InsertLeave *.css :BLReloadCSS

This function can be easily tweaked to fit your needs/workflow, and I highly recommend you do so to maximize your utility from this plugin.

## Options

	g:bl_autostart 

By default as of 2.1, Brolink will not try to connect to a socket until BLStart is called. Set this variable if it's safe to assume the Brolink.js server is running when Vim is started. I start Brolink in a startup script, so I use this feature. Mileage varies, of course.

	g:bl_no_autoupdate 

If set, Brolink won't try to reload pages/CSS when you save respective files.

	g:bl_no_mappings 

If set, Brolink won't map be, br, and bc commands.

	g:bl_serverpath 

Set if your server is not hosted on 127.0.0.1:9001. You will also need to change the socket.js file.

## Run brolink.js expediently

If you are using a Unix-like OS, you can run brolink.js so expediently:

```
sudo ln -s ~/.vim/bundle/brolink.vim/brolink/brolink.js  /usr/local/bin/
chmod  +x  ~/.vim/bundle/brolink.vim/brolink/brolink.js
```
Now, just excute `$ brolink.js` in the terminal.

## Notes

This is an experimental project, but it works really well for me, and I hope you enjoy it! I kept the source as simple as possible, and it's pretty easy to edit to your needs. I'm open to any suggestions, too, so let me know.

## Shameless plug

I hack around with Vim plugins, so [follow me](https://github.com/jaxbot) if you're into that kind of stuff (or just want to make my day) ;)
