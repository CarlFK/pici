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

    function connect(){

        const logSocket = new WebSocket(
            'WSS://'
            + window.location.host
            + '/ws/pistat/'
            + 'pi'+PiID
            + '/'
        );

        logSocket.onopen = function(e) {
            addTextAndScrollToBottom("socket connected");
            // show PoE on/off status on page (re)load.
            check_status();
        };

        logSocket.onclose = function(e) {
            const errortext = 'socket closed.';
            console.error(errortext);
            addTextAndScrollToBottom(errortext);
        };

        logSocket.onmessage = function(e) {
            const data = JSON.parse(e.data);
            addTextAndScrollToBottom(data.message);
            if (data.message == "piview: cam") {
                   refresh_video_player();
            };
        };


        document.getElementById('reconnect'+PiID).onclick = function(e) {
            logSocket.close();
            connect();
        };

        function check_status(){

            logSocket.send(
                JSON.stringify({ 'message': 'checking status: '+PiID })
            );

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

        document.getElementById('reset'+PiID).onclick = function(e) {

            e.preventDefault();

            logSocket.close();
            connect();

            logSocket.send(
                JSON.stringify({ 'message': 'reset: '+PiID })
            );

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
            logSocket.send(JSON.stringify({ 'message': message }));
            o.value = '';
        };


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

};
