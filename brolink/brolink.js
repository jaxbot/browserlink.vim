#!/usr/bin/nodejs
// Brolink.js
// The server for brolink.vim
// By Jonathan Warner, 2013
// http://github.com/jaxbot/brolink.vim

console.log("Brolink");
console.log("Server version: 2.0.0");
console.log("======================");
console.log("Dedicated to everyone who missed the first chest in OOT's Forest Temple");
console.log("");

var WebSocketServer = require("websocket").server;
var http = require("http");
var fs = require("fs");
var path = require("path");

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
		case "/reloadTemplate":
			broadcast("___RTEMPLATE");
		break;
		case "/evaluateJS":
			request.on('data', function(data) {
				broadcast(data);
			});
		break;
		case "/socket.js":
			fs.readFile(path.resolve(__dirname,"socket.js"), "utf8", function(err,data) {
                if (err) {
                    console.log(err);
                }
				response.setHeader('content-type', 'text/javascript');
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
	connection.on('message', function(msg) {
		broadcast(msg.utf8Data);
	});
	
	connections.push(connection);
});

function broadcast(data) {
	for (var i = 0; i < connections.length; i++) {
		connections[i].sendUTF(data);
	}
	console.log("Broadcast: " + data);
}

