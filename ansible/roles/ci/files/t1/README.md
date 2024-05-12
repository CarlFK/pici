Source files of a CI test.

* t1.v - (source of top.bit) wire connecting JA-1 to JA-2
* t1.py - test to see if JA-1 is connected to JA-2.
* t1.sh - script to reset, load top.bit and run the test.

This test makes sure the build process still works.

We can assume no one has rewired things from https://github.com/CarlFK/pici/wiki/Wiring-Diagram

Building top.bit from t1.v is done somewhere else, and then moved to the pi so it can be loaded onto the Arty.


