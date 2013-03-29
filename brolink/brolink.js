// Brolink.js
// The server for brolink.vim
// By Jonathan Warner, 2013
// http://github.com/jaxbot/brolink.vim

console.log("Brolink");
console.log("Server version: 1.0.0");
console.log("======================");
console.log("Dedicated to everyone who missed the first chest in OOT's Forest Temple");
console.log("");

var WebSocketServer = require("websocket").server;
var http = require("http");
var fs = require("fs");

var connections = [];

var server = http.createServer(function(request, response) {
    console.log("Requested: " + request.url);
		
	switch (request.url) {
		case "/reloadCSS":
			broadcast("___RCSS");
		break;
		case "/reloadPage":
			broadcast("___RPAGE");
		break;
		case "/evaluateJS":
			request.on('data', function(data) {
				broadcast(data);
			});
		break;
		case "/socket.js":
			fs.readFile("socket.js", "utf8", function(err,data) {
				response.writeHead(200);
				response.write(data);
				response.end();
			});
			return;
		break;
		default:
			response.writeHead(404);
			response.end();
			return;
		break;
	}
	
	response.writeHead(200);
    response.end();
    
});

server.listen(9001, function() {
    console.log("Server listening on port 9001");
});

wsServer = new WebSocketServer({
    httpServer: server,
    autoAcceptConnections: false
});

wsServer.on('request', function(request) {
    
    var connection = request.accept('', request.origin);
    console.log("Connection accepted.");
	
    connection.on('close', function(reasonCode, description) {
        console.log("Disconnected: " + connection.remoteAddress);
    });
	
	connections.push(connection);
});

function broadcast(data) {
	for (var i = 0; i < connections.length; i++) {
		connections[i].sendUTF(data);
	}
	console.log("Broadcast: " + data);
}

