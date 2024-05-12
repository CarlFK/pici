#!/bin/bash -ex

openFPGALoader -b arty --reset
openFPGALoader -b arty top.bit
python3 t1.py
