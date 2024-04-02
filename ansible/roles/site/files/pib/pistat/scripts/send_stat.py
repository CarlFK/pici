#!/srv/www/pib/venv/bin/python3

# send_stat.py - called from dnsmasq --dhcp-script=/usr/local/bin/send_stat.py

"""
https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html

--dhcp-script=<path>
  Whenever a new DHCP lease is created, or an old  one  destroyed,
  or  a  TFTP file transfer completes, the executable specified by
  this option is run.  <path> must be  an  absolute  pathname,  no
  PATH  search  occurs.   The  arguments to the process are "add",
  "old" or "del", the MAC address of the host (or DUID for IPv6) ,
  the  IP address, and the hostname, if known. "add" means a lease
  has been created, "del" means it has been destroyed, "old" is  a
  notification  of  an  existing  lease  when  dnsmasq starts or a
  change to MAC address or hostname of an  existing  lease  (also,
  lease  length  or expiry and client-id, if leasefile-ro is set).
  If the MAC address is from a network type other  than  ethernet,
  it    will    have    the    network    type    prepended,    eg
  "06-01:23:45:67:89:ab" for token ring.

  The environment is inherited from the invoker of  dnsmasq,  with
  some or all of the following variables added

 At dnsmasq startup, the script will be invoked for all existing leases as they are read from the lease file. Expired leases will be called with "del" and others with "old". When dnsmasq receives a HUP signal, the script will be invoked for existing leases with an "old" event.

There are five further actions which may appear as the first argument to the script, "init", "arp-add", "arp-del", "relay-snoop" and "tftp". More may be added in the future, so scripts should be written to ignore unknown actions. "init" is described below in --leasefile-ro

The "tftp" action is invoked when a TFTP file transfer completes: the arguments are the file size in bytes, the address to which the file was sent, and the complete pathname of the file.

  If the client provides a hostname, DNSMASQ_SUPPLIED_HOSTNAME

    dhcp-host=mac,ip,hostname
    /etc/dnsmasq.d/, which is included in my dnsmasq conf:
    dnsmasq ... --conf-dir=/etc/dnsmasq.d

"""

import argparse
import collections

import os

import send

DEBUG=False

def get_args():

    """
    The  arguments to the process are
    action: one of ["add", "old", "del"],
    MAC address of the host (or DUID for IPv6) ,
    IP address,
    hostname, if known.
    """
    # unless the first arg is tftp,
    # then it's: file size in bytes, the address to which the file was sent, and the complete pathname of the file.

    parser = argparse.ArgumentParser(
            description="""called from dnsmasq""")

    parser.add_argument('action',
            help='What the server is doing.')

    """
    parser.add_argument('mac',
            help='MAC address of the host.')

    parser.add_argument('ip',
            help='ip addresst.')

    parser.add_argument('hostname',
            nargs='?',
            default="wut?")
    """

    # next 3 args - the purpose/meaning/name is dependant on the first parameter (like "add" vs "tftp")
    parser.add_argument('p2')
    parser.add_argument('p3')
    parser.add_argument('p4', nargs='?',)

    args = parser.parse_args()

    if args.action in ["add", "old", "del"]:
        newargs = collections.namedtuple("Args", "type action mac ip hostname dsh")
        newargs.type = "dhcp"
        newargs.action = args.action
        newargs.mac = args.p2
        newargs.ip = args.p3
        newargs.hostname = args.p4 if args.p4 is not None else "(none)"
        newargs.dsh = os.getenv('DNSMASQ_SUPPLIED_HOSTNAME', "(none)")

    elif args.action in ["tftp"]:
        newargs = collections.namedtuple("Args", "type action size ip pathname")
        newargs.type = "tftp"
        newargs.action = "get"
        newargs.size = int(args.p2)
        newargs.ip = args.p3
        newargs.pathname = args.p4

    return newargs


def mk_name(ip):

    # Pie's are plugged into a port, numbered 1-48.
    # the IP is 100 + port
    # so 101 - 148.

    # the pi's hostname is "pi" + portno (no leading 0s'
    # pi1 - pi48

    # the websocket frameworks wanta a "groupname"
    # group=f"pistat_{pi_name}"
    # pistat_pi1

    octs = ip.split('.')
    o=octs[-1]
    if len(o) == 3 and o[0] == '1':
        n = int(o)-100
        pi_name=f"pi{n}"
        grp_name = f"pistat_{pi_name}"
    else:
        grp_name=None

    return grp_name

def main():
    args = get_args()

    if DEBUG:
        with open('/tmp/foo','a') as f:
            # f.write(args.__repr__())
            # f.write(f' {dsh=}\n')
            pass

    grp_name=mk_name(args.ip)
    if grp_name is not None:

        send.init(
                site_path="/srv/www/pib",
                django_settings_module="pib.settings",
                )

        if args.type == 'dhcp':
            message=f"dnsmasq: {args.type} {args.action} {args.mac} {args.ip} {args.hostname} {args.dsh}"
        elif args.type == 'tftp':
            message=f"dnsmasq: {args.type} {args.action} {args.pathname} sent {args.size:,} bytes"

        send.send_message(
                group=grp_name,
                message_type="stat.message",
                message_text=message,
                )

if __name__ == "__main__":
    main()

