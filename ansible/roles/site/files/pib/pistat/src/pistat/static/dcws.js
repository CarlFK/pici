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

    document.querySelector('#log-input'+PiID.toString()).focus();
    document.querySelector('#log-input'+PiID.toString()).onkeyup = function(e) {
        if (e.key === 'Enter') {  // enter, return
            document.querySelector('#log-submit'+PiID.toString()).click();
        }
    };

    document.querySelector('#log-submit'+PiID.toString()).onclick = function(e) {
        const messageInputDom = document.querySelector('#log-input'+PiID.toString());
        const message = messageInputDom.value;
        logSocket.send(JSON.stringify({
            'log.message': message
        }));
        messageInputDom.value = '';
    };
};

