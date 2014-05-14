/* Injected into the webpage we're linking to 
 * I recommend using GreaseMonkey or something similar to automatically inject,
 * but you can also just do something like:
 * <script src='http://127.0.0.1:9001/js/socket.js'></script>
 */

(function () {

	// Change port/address if needed 
	var socket = new WebSocket("ws://127.0.0.1:9001/");

	socket.onopen = function(evt) {  };
	socket.onclose = function(evt) {  };
	socket.onmessage = function(evt) { 
		switch (evt.data) {
			case "css":
				reloadCSS();
			break;
			case "page":
				window.location.reload();
			break;
			default:
				console.log(evt.data);
				eval(evt.data);
			break;
		}
	};
	socket.onerror = function(evt) { console.log(evt); };

	var reloadCSS = function () {
		var elements = document.getElementsByTagName("link");

		for (var i = 0; i < elements.length; i++) {
			if (elements[i].rel == "stylesheet") {
				var href = elements[i].getAttribute("data-href")
				if (href == null) {
					href = elements[i].href;
					elements[i].setAttribute("data-href", href);
				}
				elements[i].href = href + ((href.indexOf("?") == -1) ? "?" : "&") + "c=" + (new Date).getTime();
			}
		}
	}

	var log = console.log;
	console.log = function(str) {
		log.call(console, str);
		var err = (new Error).stack;
		err = err.replace("Error", "").replace(/\s+at\s/g, '@').replace(/@/g, "\n@");

		socket.send(str + "\n" + err + "\n\n");
	}
})();

