#!/bin/bash -ex
# mktftpln.sh - make tftp ln
# each pi needs a symlink: its serial number to the boot/ dir.
# because pi v3 ignores the dhcp option telling it were to find the boot files.
# so the tftp root dir will get a handfull of dumb symlinks, one for each serial number.

# run with no args to grep the logs for the serial number
# it would be nice if this hapened automatically with a dnsmasq hook, but no one has done it.

if [ $# -ne 1 ]; then
    grep "file /srv/tftp/\w*/.* not found"  /var/log/syslog
    exit
fi

id=$1

dist=bullseye
d=/srv/nfs/rpi/${dist}

ln -s ${d}/boot /srv/tftp/${id}
