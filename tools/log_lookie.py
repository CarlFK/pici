import re

from collections import defaultdict
from pprint import pprint

fn = '/home/carl/temp/syslog'

ll = "Feb 12 14:45:46 val2 dnsmasq-dhcp[215151]: 2603362573 vendor class: Linux ipconfig"

syslog_re_s = r"""
# https://stackoverflow.com/questions/53435437/parsing-a-syslog-using-regex
(?P<month>\S{3})                    #
\s+                              # added + because single digit dates might have additional spaces
(?P<date>[0-9]{1,2})              # changed {2}? to {1,2} because you might have one or two digits
\s+                              #
(?P<time>[0-9]+:[0-9]+:[0-9]+)    #
\s+                              #
(?P<hostname>\S+)                 # anything which isn't whitespace
\s+                              #
(?P<daemon>[^\[]+)                   # just in case your daemon has a digit or lower case in its name
\[                                #
(?P<pid>\d+)               #
\]                                #
:                                #
\s+                              #
"""
syslog_re_s = ''.join([l.split('#')[0].strip() for l in syslog_re_s.split('\n')])
print(syslog_re_s)
syslog_re = re.compile(syslog_re_s)
print(syslog_re)
print(ll)
match = syslog_re.match(ll)
d = match.groupdict()
pprint(d)
print("{month} {date} {time}".format(**d))

context_id_re = re.compile(syslog_re_s + r"(?P<context_id>\d+).*")

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


def get_contexts():
    """ Gather some details of the DHCP server contexts.
        One context spans multiple packets.
        One packet spans multiple syslog entries.
        Both context IDs and the key:values details we care about
    """
    contexts = defaultdict(dict)
    for line in open(fn):
        if context_match:=context_id_re.match(line):
            d = context_match.groupdict()
            k = "{month} {date} {time} {context_id}".format(**d)

            # gonna look for values getting stepped on
            old_d=contexts[k]

            if (match:=dhcp_vendor_re.match(line)):
                contexts[k].update( match.groupdict() )
                # print(contexts)

            if (match:=dhcp_type_re.match(line)):
                # context_id, client_mac, client_ip, client_hostname = match.groupdict("context_id", "client_mac", "client_ip", "client_hostname")
                contexts[k].update( match.groupdict() )
                # print(contexts)
                # break
                #contexts[context_id]['types'] this is kida weird:

                if "types" not in contexts[k]:
                    contexts[k]['types'] = []
                contexts[k]['types'].append(contexts[k]['type'])
                del( contexts[k]['type'] )

            # see if any old values got updated (stomp bad!)
            for ok in old_d:
                if (old_d[ok] is not None) and (ok != 'types'):
                    assert old_d[ok] == contexts[k][ok], (old_d[ok], contexts[k][ok])

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
    # is_weird(contexts)

def main():
    logs=get_log()


if __name__== "__main__":
    main()


