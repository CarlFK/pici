#!/bin/bash -ex

id=$1

dist=bullseye
d=/srv/nfs/rpi/${dist}

ln -s ${d}/boot /srv/tftp/${id}
