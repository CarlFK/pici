#!/bin/bash -ex
cd fpga
cd f4pga-examples

export FPGA_FAM=xc7
export F4PGA_INSTALL_DIR=~/opt/f4pga
source "$F4PGA_INSTALL_DIR/$FPGA_FAM/conda/etc/profile.d/conda.sh"
conda activate $FPGA_FAM

cd xc7
TARGET="arty_35" make -C counter_test

cd litex_demo
./src/litex/litex/boards/targets/arty.py --toolchain=symbiflow --cpu-type=picorv32 --sys-clk-freq 80e6 --output-dir build/picorv32/arty_35 --variant a7-35 --build
./src/litex/litex/boards/targets/arty.py --toolchain=symbiflow --cpu-type=vexriscv --sys-clk-freq 80e6 --output-dir build/vexriscv/arty_35 --variant a7-35 --build
cd ..

TARGET="arty_35" make -C linux_litex_demo

