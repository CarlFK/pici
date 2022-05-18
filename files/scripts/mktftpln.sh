#!/bin/bash -ex

if [ $# -ne 1 ]; then
    grep "file /srv/tftp/\w*/.* not found"  /var/log/syslog
    exit
fi

id=$1

dist=bullseye
d=/srv/nfs/rpi/${dist}

ln -s ${d}/boot /srv/tftp/${id}
