# PiCI

Raspberry Pi CI for FPGA tool chain.

Overview:

There is a server that holds all the files.
Pi's do no have any local storage.

(outdated, there is now a bunch of ansible...)

setup.md - steps for human to prep a box for setup2.sh
setup2.sh - script to setup server for pis to netboot from.
setup3.sh - script to run on a pi when the server is in update state.

https://docs.google.com/document/d/1H3x34bdztWy-uN8EYe-FxJL2YojIjd-0feL9d8BMtN4/edit#heading=h.d8vkktb69rj3

Now Live from ps1: https://fpga-gw-ps1.mithis.com

Coming soon:

ssh client in the browser: https://github.com/eevelweezel/pibsite  which is an implemtation of the webssh client: https://github.com/huashengdun/webssh

browser UI to the SNMP controled PoE to turn the pis off and on again.

Wondering what this is all about?  Start here https://f4pga.org
