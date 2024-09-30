#!/bin/bash -ex

openFPGALoader -b arty top.bit
echo now wait for video time to catch up with prompt time: $(date +%H:%M:%S)
