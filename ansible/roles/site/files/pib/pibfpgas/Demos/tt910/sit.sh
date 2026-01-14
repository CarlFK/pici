#!/bin/bash -ex
#
# sit.sh - send it
# sends a file to the tt910 via little_term.py

cat demo.sh | cstream -b 1 -t 30 > /dev/ttyACM0
