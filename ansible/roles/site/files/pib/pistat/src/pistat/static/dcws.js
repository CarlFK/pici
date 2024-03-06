// dcws.js
// Django-Channels Web Socket

function PiStatus(PiID) {

    function addTextAndScrollToBottom(newText){
        const textBox = document.getElementById("log"+PiID);
        textBox.value += (newText + '\n');
        textBox.scrollTop = textBox.scrollHeight; // Scroll to bottom
    };

    function connect(){
	const logSocket = new WebSocket(
	    'wss://'
	    + window.location.host
	    + '/ws/pistat/'
	    + 'pi'+PiID
	    + '/'
	);

	logSocket.onclose = function(e) {
	    const errortext = 'socket was closed.';
	    console.error(errortext);
	    addTextAndScrollToBottom(errortext);
	};

	logSocket.onmessage = function(e) {
	    const data = JSON.parse(e.data);
	    addTextAndScrollToBottom(data.message);
	    if (data.message == "piview: cam") {
	    	document.getElementById("my-video"+PiID).player.load();
	    };
		    };

	document.querySelector('#reconnect'+PiID).onclick = function(e) {
	    logSocket.close();
	    connect();
	};

	document.querySelector('#submit-reset'+PiID).onclick = function(e) {

	    e.preventDefault();

	    logSocket.send(
		JSON.stringify({ 'message': 'reset: '+PiID })
	    );

	    fetch('/snmp/toggle', {
	      method: 'POST',
		// name="port" value="2"
		// { "port": PiID }
	      body: new FormData(document.querySelector('#form-reset'+PiID))
	      // body: JSON.stringify({ port: [PiID,] }),
	      // headers: { "Content-type": "application/json; charset=UTF-8" }
	      }
	    )
	    .then((error) => console.log(error));
	};


	document.querySelector('#submit-status'+PiID).onclick = function(e) {

	    e.preventDefault();

	    logSocket.send(
		JSON.stringify({ 'message': 'status: '+PiID })
	    );

	    fetch('/snmp/status', {
	      method: 'POST',
		// name="port" value="2"
		// { "port": PiID }
	      body: new FormData(document.querySelector('#form-reset'+PiID))
	      // body: JSON.stringify({ port: [PiID,] }),
	      // headers: { "Content-type": "application/json; charset=UTF-8" }
	      }
	    )
	      .then((response) => response.json())
	      .then((json) => console.log(json));
	    // .then((error) => console.log(error))
	};

	document.querySelector('#log-submit'+PiID).onclick = function(e) {
	    const messageInputDom = document.querySelector('#log-input'+PiID);
	    const message = 'send: ' + messageInputDom.value;
	    logSocket.send(JSON.stringify({
		'message': message
	    }));
	    messageInputDom.value = '';
	};

        addTextAndScrollToBottom("connected");

    };
    
    connect();

    document.querySelector('#log-input'+PiID).onkeyup = function(e) {
        if (e.key === 'Enter') {  // enter, return
            document.querySelector('#log-submit'+PiID).click();
        }
    };

};
