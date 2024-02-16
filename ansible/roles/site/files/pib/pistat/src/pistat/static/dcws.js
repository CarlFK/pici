// dcws.js
// Django-Channels Web Socket

function PiStatus(PiID) {

    const logSocket = new WebSocket(
        'wss://'
        + window.location.host
        + '/ws/pistat/'
        + 'pi'+PiID.toString()
        + '/'
    );

    logSocket.onmessage = function(e) {
        const data = JSON.parse(e.data);
        document.querySelector('#log'+PiID.toString()).value += (data.message + '\n');
    };

    logSocket.onclose = function(e) {
        console.error('socket closed unexpectedly');
    };

    document.querySelector('#message-input2').focus();
    document.querySelector('#message-input2').onkeyup = function(e) {
        if (e.key === 'Enter') {  // enter, return
            document.querySelector('#message-submit2').click();
        }
    };

    document.querySelector('#message-submit2').onclick = function(e) {
        const messageInputDom = document.querySelector('#message-input2');
        const message = messageInputDom.value;
        logSocket.send(JSON.stringify({
            'message': message
        }));
        messageInputDom.value = '';
    };
};

