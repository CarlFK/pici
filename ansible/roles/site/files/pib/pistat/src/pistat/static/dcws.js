// dcws.js
// Django-Channels Web Socket

function PiStatus(PiID) {

    const logSocket = new WebSocket(
        'wss://'
        + window.location.host
        + '/ws/pistat/'
        + 'pi'+PiID
        + '/'
    );

    function addTextAndScrollToBottom(newText){
        const textBox = document.getElementById("log"+PiID);
        textBox.value += (newText + '\n');
        textBox.scrollTop = textBox.scrollHeight; // Scroll to bottom
    };

    addTextAndScrollToBottom("connected");

    logSocket.onclose = function(e) {
        const errortext = 'socket closed, refresh page to reconnect.';
        console.error(errortext);
        addTextAndScrollToBottom(errortext);
    };

    logSocket.onmessage = function(e) {
        const data = JSON.parse(e.data);
        addTextAndScrollToBottom(data.message);
		};

    document.querySelector('#log-input'+PiID).onkeyup = function(e) {
        if (e.key === 'Enter') {  // enter, return
            document.querySelector('#log-submit'+PiID).click();
        }
    };

    document.querySelector('#log-submit'+PiID).onclick = function(e) {
        const messageInputDom = document.querySelector('#log-input'+PiID);
        const message = 'send: ' + messageInputDom.value;
        logSocket.send(JSON.stringify({
            'message': message
        }));
        messageInputDom.value = '';
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

};
