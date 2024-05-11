#!/bin/bash -ex

pi=pi@10.21.0.102

cd fpga
cd f4pga-examples
cd xc7

cd counter_test
scp build/arty_35/top.bit ${pi}:Uploads
ssh ${pi} "openFPGALoader -b arty Uploads/top.bit"
cd ..

cd litex_demo
scp build/picorv32/arty_35/gateware/arty.bit ${pi}:Uploads
ssh ${pi} "openFPGALoader -b arty Uploads/arty.bit"
scp build/vexriscv/arty_35/gateware/arty.bit ${pi}:Uploads
ssh ${pi} "openFPGALoader -b arty Uploads/arty.bit"
cd ..

exit

cd linux_litex_demo
scp -r \
    buildroot emulator build/arty_35/top.bit \
    ${pi}:Uploads

ssh ${pi} "sudo mv -v Uploads/*/* /srv/tftp/"
ssh ${pi} "openFPGALoader -b arty Uploads/top.bit"
