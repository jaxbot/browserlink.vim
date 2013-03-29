# Brolink.vim
Brolink is a live web editing plugin for Vim. I really can't explain it well, so here's a GIF:

<img src='https://raw.github.com/jaxbot/brolink.vim/master/brolink.gif'>

## How it works
Brolink is very simple. The plugin itself hooks autocommands for file changes (and a few other things) cURL calls. The calls are sent to a node.js backend, which your webpage connects to. The entire process happens extremely fast.

Video: http://www.youtube.com/watch?v=w4_fkpVQbAQ

## Installation and Setup
To install, either download the repo, or as I would recommend, use [Pathogen](https://github.com/tpope/vim-pathogen).

	git clone git://github.com/jaxbot/brolink.vim.git

Once installed, make sure you have Node installed, and run the server program like so:

	node brolink.js

Feel free to move (or symlink) the brolink server to a more convenient location.

Once Brolink is running in a console, you need to include a reference to it in your web project.
Two options:

1. Be lazy and add this to your page(s)
	
	<script src='http://127.0.0.1:9001/socket.js'></script>

2. Use GreaseMonkey or Tampermonkey to automatically embed in your local projects, e.g.


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


I prefer the latter, as it's more universal and I don't have extra development junk in my projects. But it's totally up to you, bro.

## Usage

Once set up, Vim should now call the Node server whenever you save a .html, .js, .php, or .css file. 
In addition:

	BLReloadPage

will reload the current pages

	BLReloadCSS

will reload the current stylesheets 

	BLEvaluateBuffer

will evaluate the current buffer

You can also use <leader>be to evaluate selections or buffers, <leader>br to reload, and <leader>bc to reload stylesheets manually.

## Options

	g:bl_no_autoupdate 

If set, Brolink won't try to reload pages/CSS when you save respective files.

	g:bl_no_mappings 

If set, Brolink won't map be, br, and bc commands.

	g:bl_serverpath 

Set if your server is not hosted on 127.0.0.1:9001. You will also need to change the socket.js file.

## Notes

This is an experimental project, but it works really well for me, and I hope you enjoy it! I kept the source as simple as possible, and it's pretty easy to edit to your needs. I'm open to any suggestions, too, so let me know.
