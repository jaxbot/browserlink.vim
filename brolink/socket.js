/* Injected into the webpage we're linking to 
 * I recommend using GreaseMonkey or something similar to automatically inject,
 * but you can also just do something like:
 * <script src='http://127.0.0.1/socket.js'></script>
 */

var ___brolink = function () {

	// Change port/address if needed 
	var socket = new WebSocket("ws://127.0.0.1:9001/");

	socket.onopen = function(evt) {  };
	socket.onclose = function(evt) {  };
	socket.onmessage = function(evt) { 
		switch (evt.data) {
			case "___RCSS":
				___brolink_reloadcss();
			break;
			case "___RPAGE":
				window.location.reload();
			break;
			case "___RTEMPLATE": //p18 stuff
				TEMPLATES = [];
				renderPageFromTemplate();
			break;
			default:
				console.log(evt.data);
				eval(evt.data);
			break;
		}
	};
	socket.onerror = function(evt) { console.log(evt); };

	function ___brolink_reloadcss() {
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
}();
