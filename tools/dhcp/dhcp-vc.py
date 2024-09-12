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

    def remove_roages(logs):
        """
        fn='/home/carl/src/tv/pib/pici/ansible/inventory/host_vars/ps1.fpgas.online'
        s=open(fn).read()

        pi_macs=['b8:27:eb:2f:5d:08', 'dc:a6:32:05:32:45', 'b8:27:eb:d4:f1:74', 'b8:27:eb:33:51:27', 'b8:27:eb:a3:51:b4', 'b8:27:eb:51:01:df', 'b8:27:eb:68:fc:e7', 'b8:27:eb:69:79:a0', 'b8:27:eb:5f:de:85', 'b8:27:eb:0c:f8:43']
        wonky_macs= [ "b8:27:eb:5a:26:5b", "e4:5f:01:64:75:c6" '46:63:56:3c:80:85' ]

        logs = [
                log for log in logs
                    if log['mac'] in pi_macs
                ]

        return logs


    def spackle(logs):
        mac_to_hostname=defaultdict()

        # find all the mac:hostnames that exist
        for d in logs:
            if d['hostname'] is not None:
                mac_to_hostname[d['mac']] =  d['hostname']

        # fill in all the hostnames
        for d in logs:
            if d['mac'] in mac_to_hostname:
                d['host_name'] = mac_to_hostname[d['mac']]
            else:
                print(f"roage mac: {d['mac']}")
                pprint(d)

    logs = remove_roages(logs)
    logs=spackle(logs)

    ret = {}

    # pis=set()
    vcs=set()
    stats={} # defaultdict(defaultdict(int))

    for d in logs:

        # pis.add(d['hostname'])
        vcs.add(d['vendor_class'])

        if d['mac'] not in stats:
            stats[d['mac']] = defaultdict(int)

        stats[d['mac']][d['vendor_class']] +=1


    # ret['pis'] = pis
    ret['vcs'] = vcs
    ret['stats'] = stats
    # ret['mac_to_hostname'] = mac_to_hostname

    return ret



def focus(answers, args):

    if args.hostname:
        # answers = [d for d in answers if d['hostname'] == args.hostname ]
        answers = filter( lambda d: d['hostname'] == args.hostname, answers )

    return answers


def show_answers(answers):

    stats = answers['stats']
    for k in stats:

        host_name = stats[k]['hostname']

        if host_name[:2] == 'pi':
            print(host_name)
            pprint(stats[k])
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

    parser.add_argument('--host',
            help="only show [hostname]")

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

