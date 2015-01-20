/* Injected into the webpage we're linking to 
 * I recommend using GreaseMonkey or something similar to automatically inject,
 * but you can also just do something like:
 * <script src='http://127.0.0.1:9001/js/socket.js'></script>
 */

(function () {

	// Change port/address if needed 
	var socket = new WebSocket("ws://127.0.0.1:9001/");

	// Function to handle visible/non-visible. From http://stackoverflow.com/a/19519701
	var visible = (function(){
		// Determine the state and event keys.
		var stateKey, eventKey, keys = {
			hidden: "visibilitychange",
			webkitHidden: "webkitvisibilitychange",
			mozHidden: "mozvisibilitychange",
			msHidden: "msvisibilitychange"
		};
		for (stateKey in keys) {
			if (stateKey in document) {
				eventKey = keys[stateKey];
				break;
			}
		}

		// Build the function using this key.
		vis = function(cb) {
			// If one is given, register a callback.
			if (cb) {
				document.addEventListener(eventKey, function() {
					cb(vis()); 
				});
			}

			// Return the current state.
			return !document[stateKey];
		}
		return vis;
	})();

	// Listen for window visible and non-visible.
	var pendingReload = false;
	visible(function(vis) {
		if (vis && pendingReload) {
			window.location.reload();
			pendingReload = false;
		}
	});

	socket.onopen = function(evt) {  };
	socket.onclose = function(evt) {  };
	socket.onmessage = function(evt) { 
		switch (evt.data) {
			case "css":
				reloadCSS();
			break;
			case "page":
				if (visible()) {
					window.location.reload();
				} else {
					pendingReload = true;
				}
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

		var c = 0;

		for (var i = 0; i < elements.length; i++) {
			if (elements[c].rel == "stylesheet") {
				var href = elements[i].getAttribute("data-href");

				if (href == null) {
					href = elements[c].href;
					elements[c].setAttribute("data-href", href);
				}

				if (window.__BL_OVERRIDE_CACHE) {
					var link = document.createElement("link");
					link.href = href;
					link.rel = "stylesheet";
					document.head.appendChild(link);

					document.head.removeChild(elements[c]);

					continue;
				}
				elements[i].href = href + ((href.indexOf("?") == -1) ? "?" : "&") + "c=" + (new Date).getTime();
			}
			c++;
		}
	}

	if (!window.__BL_NO_CONSOLE_OVERRIDE) {
		var log = console.log;
		console.log = function(str) {
			log.call(console, str);
			var err = (new Error).stack;
			err = err.replace("Error", "").replace(/\s+at\s/g, '@').replace(/@/g, "\n@");
			socket.send(JSON.stringify({
				"type"       : "log",
				"message"    : str,
				"stacktrace" : err
			}));
		}
	}

	window.onerror = function(msg, url, lineNumber) {
		socket.send(JSON.stringify({
			"type"       : "error",
			"message"    : msg,
			"url"        : url,
			"lineNumber" : lineNumber
		}));
		return false;
	}
})();

