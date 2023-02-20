import re

from collections import defaultdict
from pprint import pprint

fn = '/home/carl/temp/syslog'

server_id_re = re.compile(r"dnsmasq-dhcp\[(?P<server_id>\d+)\]")

context_id_re = re.compile(r".*dnsmasq-dhcp\[(?P<server_id>\d+)\]:\s+(?P<context_id>\d+).*")

"""
#define DHCPDISCOVER             1
#define DHCPOFFER                2
#define DHCPREQUEST              3
#define DHCPDECLINE              4
#define DHCPACK                  5
#define DHCPNAK                  6
#define DHCPRELEASE              7
#define DHCPINFORM               8
"""

dhcp_type_re = re.compile(r".*dnsmasq-dhcp\[(?P<server_id>\d+)\]:\s+(?P<context_id>\d+)\s+"
    "(?P<type>(DHCPDISCOVER|DHCPOFFER|DHCPREQUEST|DHCPDECLINE|DHCPACK|DHCPNAK|DHCPRELEASE|DHCPINFORM))\(eth-local\)\s+"
    "(?P<client_ip>\d+\.\d+\.\d+\.\d+)\s+"
    "(?P<client_mac>\w+:\w+:\w+:\w+:\w+:\w+)"
    "(?:\s*(?P<client_hostname>\w+))?", re.VERBOSE)

# Feb 12 14:45:46 val2 dnsmasq-dhcp[215151]: 2603362573 vendor class: Linux ipconfig
dhcp_vendor_re = re.compile(r".*dnsmasq-dhcp\[(?P<server_id>\d+)\]:\s+(?P<context_id>\d+)\s+"
    "vendor class: (?P<vendor_class>.*)")


def get_dhcp_server_id():
    """ Search for log lines from dnsmasq-dhcp, gather the service ID

        In the log provided, the dnsmasq-dhcp service always identifies itself as '215151'
    """

    resultset = set()
    for line in open(fn):
        match = server_id_re.search(line)
        if match is not None:
            resultset.add(match.group("server_id"))
    return resultset

def get__ids():
    """ Gather the IDs of DHCP server s.
        One  spans multiple syslog entries.

        7385 s from the DHCP server in the log provided.

        One thing this function does tell us is that the DHCP server is always
        responding to a client, since there are no lines with a server ID but no client ID
    """
    resultset = set()
    for line in open(fn):
        server_match = server_id_re.search(line)
        context_match = context_id_re.search(line)
        if server_match is not None and context_match is None:
            print(f"Odd line: {line}")
            # No odd lines found
        elif context_match is not None:
            resultset.add(_match.group("context_id"))
    return resultset

def group_lines_by_context_id():
    """ Group DHCP log lines by log ID

        Unsurprisingly, there are 7385 groups in the results
    """
    resultdict = dict()
    for line in open(fn):
        if (match:=context_id_re.search(line)) is not None:
            resultdict.setdefault(match.group("context_id"), list()).append(line)
    return resultdict

def get_contexts():
    """ Gather some details of the DHCP server contexts.
        One context spans multiple packets.
        One packet spans multiple syslog entries.
        Both context IDs and the key:values details we care about
    """
    contexts = defaultdict(dict)
    for line in open(fn):
        if context_match:=context_id_re.match(line):
            context_id= context_match.group("context_id")

            # gonna look for values getting stepped on
            old_d=contexts[context_id]

            if (match:=dhcp_vendor_re.match(line)):
                contexts[context_id].update( match.groupdict() )
                # print(contexts)

            if (match:=dhcp_type_re.match(line)):
                # context_id, client_mac, client_ip, client_hostname = match.groupdict("context_id", "client_mac", "client_ip", "client_hostname")
                contexts[context_id].update( match.groupdict() )
                # print(contexts)
                # break
                #contexts[context_id]['types'] this is kida weird:

                if "types" not in contexts[context_id]:
                    contexts[context_id]['types'] = []
                contexts[context_id]['types'].append(contexts[context_id]['type'])
                del( contexts[context_id]['type'] )

            # see if any old values got updated (stomp bad!)
            for k in old_d:
                if (old_d[k] is not None) and (k != 'types'):
                    assert old_d[k] == contexts[context_id][k], (old_d[k], contexts[context_id][k])

    return contexts


def mac_maps():
    """ Map MAC addresses to hostnames"""
    mac_to_ID = defaultdict(set)
    mac_to_IP = defaultdict(set)
    mac_to_hostname = defaultdict(set)
    for line in open(fn):
        if (match:=dhcp_type_re.search(line)) is not None:
            context_id, client_mac, client_ip, client_hostname = match.group("context_id", "client_mac", "client_ip", "client_hostname")
            mac_to_ID[client_mac].add(_id)
            mac_to_IP[client_mac].add(client_ip)
            if client_hostname is not None:
                mac_to_hostname[client_mac].add(client_hostname)
    return mac_to_ID, mac_to_IP, mac_to_hostname

def gd():
    mac_to_ID, mac_to_IP, mac_to_hostname = mac_maps()
    lines_by__id = group_lines_by_context_id()

    #Let's see if there are more transactions for particular hosts:
    trans_per_mac = {k: len(v) for k, v in mac_to_ID.items()}
    trans_per_host = {mac_to_hostname.get(k, {k}).pop(): v for k, v in trans_per_mac.items()}
    from pprint import pprint
    pprint(trans_per_host)

def is_weird(contexts):
    # look for weird

    # results:
    # context_id is not unique. So gonna add the timetamp and see what happens.

    for i in range(10):

        for k in contexts:
            if len(contexts[k]['types'] ) == i:
                if contexts[k]['client_hostname'] in [ 'netgear', 'netgear2' ]:
                    continue
                else:
                    print(k)
                    pprint(contexts[k])
                    print()
                    break


def get_log():
    contexts = get_contexts()
    is_weird(contexts)

def main():
    logs=get_log()


if __name__== "__main__":
    main()


