#!/usr/bin/python3

# dhcp-logger.py - called from dnsmasq --dhcp-script=dhcp-logger.py

"""
man dnsmasq
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
  "06-01:23:45:67:89:ab" for token ring. The  process  is  run  as
  root  (assuming that dnsmasq was originally run as root) even if
  dnsmasq is configured to change UID to an unprivileged user.

  The environment is inherited from the invoker of  dnsmasq,  with
  some or all of the following variables added

  If the client provides a hostname, DNSMASQ_SUPPLIED_HOSTNAME

    dhcp-host=mac,ip,hostname
    /etc/dnsmasq.d/, which is included in my dnsmasq conf:
    dnsmasq ... --conf-dir=/etc/dnsmasq.d

  See --dhcp-hostsdir for a way of getting new host entries read
  automatically.

 Primary key in leases database is IP, to "add" happens when IP address
 is new, "old" for existing IP address, but other data changes.

  and where the hostname comes from (client or server)

  either, if both available, server overrides.
"""

# DNSMASQ_VENDOR_CLASS

import argparse
import datetime
import json
import os

DEBUG=True

def add_to_file(filename, line):

    with open(filename,'a') as f:
        f.write(line+'\n')

def log_me(args):

    d = {}
    d['timestamp'] = datetime.datetime.now().isoformat()
    d['vendor_class'] = os.getenv('DNSMASQ_VENDOR_CLASS', "no vc")
    d['mac']=args.mac
    d['ip']=args.ip
    d['hostname']=args.hostname

    line = json.dumps(d)
    add_to_file(args.filename, line)


def get_args():

    """
    The  arguments to the process are
    action: one of ["add", "old", "del"],
    MAC address of the host (or DUID for IPv6) ,
    IP address,
    hostname, if known.
    """

    parser = argparse.ArgumentParser(
            description="""called from dnsmasq""")

    parser.add_argument('action',
            help='What the server is doing.')

    parser.add_argument('mac',
            help='MAC address of the host.')

    parser.add_argument('ip',
            help='ip addresst.')

    parser.add_argument('hostname',
            nargs='?',
            default=None)

    parser.add_argument('--filename',
            default="/var/log/dnsmasq/vc.jsons",
            help='File to save mac/hostnames (overide for testing)')

    args = parser.parse_args()

    return args


def main():
    args = get_args()

    if DEBUG:
        with open('/tmp/foo','a') as f:
            f.write(args.__repr__())
            f.write('\n')
            f.write(os.getenv('DNSMASQ_SUPPLIED_HOSTNAME', "oh no!"))
            f.write('\n')
            f.write(os.getenv('DNSMASQ_VENDOR_CLASS', "oh noze!"))
            f.write('\n')

    if args.action in ["add", "old",]:
        log_me(args)

if __name__ == "__main__":
    main()

