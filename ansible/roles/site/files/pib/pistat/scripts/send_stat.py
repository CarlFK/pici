#!/srv/www/pib/venv/bin/python3

# send_stat.py - called from dnsmasq --dhcp-script=/usr/local/bin/send_stat.py

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

"""

import argparse
import os

import send

DEBUG=True

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
            default="wut?")

    args = parser.parse_args()

    return args


def mk_name(ip):
    octs = ip.split('.')
    o=octs[-1]
    if len(o) == 3 and o[0] == '1':
        n = int(o)-100
        pi_name=f"pi{n}"
    else:
        pi_name=None
    return pi_name

def main():
    args = get_args()

    if DEBUG:
        with open('/tmp/foo','a') as f:
            f.write(args.__repr__())
            f.write('\n')
            f.write(os.getenv('DNSMASQ_SUPPLIED_HOSTNAME', "oh no!"))
            f.write('\n')

    send.init(
            site_path="/srv/www/pib",
            django_settings_module="pib.settings",
            )

    pi_name=mk_name(args.ip)
    if pi_name is not None:

        message=f"dhcp: {args.action} {args.mac} {args.ip} {args.hostname}"
        send.send_message(
                group=f"pistat_{pi_name}",
                message_type="stat.message",
                message_text=message,
                )

if __name__ == "__main__":
    main()
