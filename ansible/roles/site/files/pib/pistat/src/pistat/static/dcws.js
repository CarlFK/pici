// dcws.js
// Django-Channels Web Socket

function PiStatus(PiID) {

    function addTextAndScrollToBottom(newText){
        const o = document.getElementById("log"+PiID);
        d=new Date();
        o.value += (d.toLocaleTimeString() + ': ' + newText + '\n');
        o.scrollTop = o.scrollHeight; // Scroll to bottom
    };

    function refresh_video_player(){
        const o = document.getElementById("video-player"+PiID);
        o.player.load();
    };

    function wssh_connect(){
        const wssh_if = document.getElementById("wssh_if").contentWindow;
        wssh_if.wssh.connect();
    };

    function pi_ping(){

        fetch('/pistat/ping/pi'+PiID, {
          method: 'POST',
          headers: { "Content-type": "application/json; charset=UTF-8" },
          body: JSON.stringify({ port: PiID })
          }
        )
          .then((response) => response.json())
          .then((json) => console.log(json))
          .then((error) => console.log(error));
    };

    // The log socket reconnects by itself: 1 s after it drops, doubling up
    // to 30 s while the server stays unreachable. The delay only goes back
    // to 1 s once a connection has stayed up for 30 s, so a server that
    // accepts and then drops every socket gets the backoff too, not one
    // reconnect (and one SNMP status query) a second. Messages sent while
    // it is down are queued and go out when it is back.
    let logSocket = null;
    let retryTimer = null;
    let retryDelay = 1000;
    let stableTimer = null;
    const pending = [];

    function send(message){
        const payload = JSON.stringify({ 'message': message });
        if (logSocket !== null && logSocket.readyState === WebSocket.OPEN) {
            logSocket.send(payload);
        } else {
            pending.push(payload);
        }
    };

    function connect(){

        clearTimeout(retryTimer);
        retryTimer = null;
        clearTimeout(stableTimer);
        if (logSocket !== null) {
            // Replaced on purpose: its onclose sees it is no longer
            // logSocket and does not schedule a reconnect of its own.
            logSocket.close();
        }

        const socket = new WebSocket(
            'WSS://'
            + window.location.host
            + '/ws/pistat/'
            + 'pi'+PiID
            + '/'
        );
        logSocket = socket;

        socket.onopen = function(e) {
            stableTimer = setTimeout(function() { retryDelay = 1000; }, 30000);
            addTextAndScrollToBottom("socket connected");
            // show PoE on/off status on page (re)load.
            check_status();
            while (pending.length > 0) {
                socket.send(pending.shift());
            }
        };

        socket.onclose = function(e) {
            if (socket !== logSocket) {
                return;
            }
            clearTimeout(stableTimer);
            const errortext = 'socket closed, reconnecting in ' + retryDelay / 1000 + ' s.';
            console.error(errortext);
            addTextAndScrollToBottom(errortext);
            retryTimer = setTimeout(connect, retryDelay);
            retryDelay = Math.min(retryDelay * 2, 30000);
        };

        socket.onmessage = function(e) {
            const data = JSON.parse(e.data);
            addTextAndScrollToBottom(data.message);

            // reconnect UI clients to the server(s)
            if (data.message == "piview: ssh ssh server started.") {
                   console.log("ssh!");
                   wssh_connect();
            };
            if (data.status == "cam") {
                   refresh_video_player();
            };
        };

    };

    function check_status(){

        send('checking status: '+PiID);

        fetch('/snmp/status', {
          method: 'POST',
          headers: { "Content-type": "application/json; charset=UTF-8" },
          body: JSON.stringify({ port: PiID })
          }
        )
          .then((response) => response.json())
          .then((json) => console.log(json))
          .then((error) => console.log(error));
    };

    document.getElementById('reconnect'+PiID).onclick = function(e) {
        connect();
    };

    document.getElementById('reset'+PiID).onclick = function(e) {

        e.preventDefault();

        // A fresh socket now, rather than whenever the backoff would next
        // retry, so none of the boot messages are missed.
        connect();

        send('reset: '+PiID);

        fetch('/snmp/toggle', {
          method: 'POST',
          headers: { "Content-type": "application/json; charset=UTF-8" },
          body: JSON.stringify({ port: PiID })
          }
        )
        .then((error) => console.log(error));
    };

    document.getElementById('status'+PiID).onclick = function(e) {
        e.preventDefault();
        check_status();
    };

    document.getElementById('log-submit'+PiID).onclick = function(e) {
        const o = document.getElementById('log-text'+PiID);
        message = o.value;
        if (message == ''){ message=o.placeholder };
        send(message);
        o.value = '';
    };

    connect();

    document.getElementById('log-text'+PiID).onkeyup = function(e) {
        if (e.key === 'Enter') {  // enter, return
            document.getElementById('log-submit'+PiID).click();
        }
    };

    document.getElementById("refresh-video-player"+PiID).onclick = function(e) {
    	refresh_video_player(e);
    };

    document.getElementById("wssh-connect").onclick = function(e) {
    	wssh_connect();
    };

    document.getElementById("pi-ping").onclick = function(e) {
    	pi_ping();
    };

};
