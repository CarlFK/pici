#!/srv/www/pib/venv/bin/python3

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

"""

import datetime

from twisted.internet.protocol import DatagramProtocol
from twisted.internet import reactor

import send
from send_stat import mk_name

def log(text, address=None):
    """ make noise, dispaly the text, append to log file """
    line=f"{address} {text}"
    print( "\x07", line, end="" )
    # open('ncc.log','a').write(line)

def send_line(message, address):

    grp_name=mk_name(address)
    if grp_name is not None:

        send.send_message(
                group=grp_name,
                message_type="stat.message",
                message_text=message,
                )


class LogUDP(DatagramProtocol):
    def __init__(self):
    # for those times when we miss the start command
        self.start_time=None

    def datagramReceived(self, datagram, address):
        datagram = datagram.decode()
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
            log(datagram, address[0])
            # import code; code.interact(local=locals())
            send_line(datagram.strip(), address[0])

def main():

    send.init(
            site_path="/srv/www/pib",
            django_settings_module="pib.settings",
            )

    hp=reactor.listenUDP(6666, LogUDP()).getHost()
    print( "listening on %s" % hp )
    log("\nlogger started: %s\n" % datetime.datetime.now())
    reactor.run()

if __name__ == '__main__':
    main()
