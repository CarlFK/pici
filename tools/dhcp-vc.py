#!/usr/bin/python3

import argparse
import datetime
import json

from collections import defaultdict
from pprint import pprint

def get_log(args):

    logs = []
    with open(args.filename,'r') as f:
        for line in f:
            line = line.strip('\n')
            d = json.loads(line)
            logs.append(d)

    return logs

def get_answers(logs):

    ret = {}

    mac_to_hostname=defaultdict()

    # pis=set()
    vcs=set()
    stats={} # defaultdict(defaultdict(int))

    for d in logs:

        if d['hostname'] is not None:
            mac_to_hostname[d['mac']] =  d['hostname']

        # pis.add(d['hostname'])
        vcs.add(d['vendor_class'])

        if d['mac'] not in stats:
            stats[d['mac']] = defaultdict(int)

        stats[d['mac']][d['vendor_class']] +=1

    # ret['pis'] = pis
    ret['vcs'] = vcs
    ret['stats'] = stats
    ret['mac_to_hostname'] = mac_to_hostname

    return ret

def show_answers(answers):

    stats = answers['stats']
    for mac in stats:

        if mac in answers['mac_to_hostname']:

            host_name = answers['mac_to_hostname'][mac]

            if host_name[:2] == 'pi':
                print(host_name)
                pprint(stats[mac])
                print()



def debug(args):

    with open('/tmp/foo','a') as f:
        f.write(args.__repr__())
        f.write('\n')
        f.write(os.getenv('DNSMASQ_SUPPLIED_HOSTNAME', "oh no!"))
        f.write('\n')
        f.write(os.getenv('DNSMASQ_VENDOR_CLASS', "oh noze!"))
        f.write('\n')


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

    parser.add_argument('--filename',
            default="vc.jsons",
            help='File to save mac/hostnames (overide for testing)')

    parser.add_argument('--debug',
            default=False,
            help="append 'rawr' data to /tmp/foo")

    args = parser.parse_args()

    return args


def main():
    args = get_args()

    if args.debug:
        debug(args)

    logs = get_log(args)
    # pprint(logs[:3])

    answers = get_answers(logs)
    show_answers(answers)

if __name__ == "__main__":
    main()

