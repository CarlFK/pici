#!/bin/bash -ex
#
# sit.sh - send it
# sends a file to the tt06 910 kianv1 via little_term.py

cat ${1} | cstream -b 1 -t 30 > /dev/serial/by-id/usb-MicroPython_Board_in_FS_mode_de640cb1d3975a26-if00
