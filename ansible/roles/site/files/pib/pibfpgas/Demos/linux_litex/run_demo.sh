#!/bin/bash -ex

cp -v tftp/* /srv/tftp
openFPGALoader -b arty top.bit
tio /dev/ttyUSB1
