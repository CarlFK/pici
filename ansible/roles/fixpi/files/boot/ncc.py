#!/usr/bin/python

# netcons server - logs netconsole dumps,
# tracks time between hits
"""
netconsole=[+][src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]
netconsole=@/,@10.21.0.1/
https://www.kernel.org/doc/Documentation/networking/netconsole.txt

client setup:
NETCONSLOGR=g2a
echo "start" | netcat -q 1 -u $NETCONSLOGR 6666
sudo modprobe netconsole netconsole="@/,@$NETCONSLOGR/"
append ... netconsole=@192.156.1.5/eth0,@192.168.1.3/00:08:02:a0:ab:cf

or because this ncc.py isn't working:
nc -u -l -p 6666
"""

import datetime

from twisted.internet.protocol import DatagramProtocol
from twisted.internet import reactor

def log(text):
    """ make noise, dispaly the text, append to log file """
    print( "\x07", text, end="" )
    open('ncc.log','a').write(text)

class LogUDP(DatagramProtocol):
    def __init__(self):
	# for those times when we miss the start command
        self.start_time=None

    def datagramReceived(self, datagram, address):
        this_time=datetime.datetime.now()
        if datagram=="start\n":
            # reset the 'stopwatch'
            self.start_time=this_time
            log("\nstarted: %s\n" % (this_time))
        else:
            if self.start_time:
                elapsed=this_time-self.start_time
                log("\nelasped: %s min.\n" % (elapsed.seconds/60.0))
                # kill the clock, we don't want any more timings
                self.start_time=None
            log(str(datagram))

def main():
    # hp=reactor.listenUDP(6666, LogUDP()).getHost()
    hp=reactor.listenUDP(6666, LogUDP(), interface="10.21.0.1").getHost()
    print( f"listening on {hp}" )
    log("\nlogger started: %s\n" % datetime.datetime.now())
    reactor.run()

if __name__ == '__main__':
    main()
