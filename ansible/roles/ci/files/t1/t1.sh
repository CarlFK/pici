#!/bin/bash -ex

cd $(dirname "$0")
openFPGALoader -b arty --reset
openFPGALoader -b arty top.bit
python3 t1.py
