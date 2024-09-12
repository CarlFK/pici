set -ex

export F4PGA_INSTALL_DIR=~/opt/f4pga
export FPGA_FAM=xc7
source "$F4PGA_INSTALL_DIR/$FPGA_FAM/conda/etc/profile.d/conda.sh"
conda activate

# /home/carl/opt/f4pga/xc7/conda/envs/xc7/bin/symbiflow_synth
PATH=$F4PGA_INSTALL_DIR/$FPGA_FAM/conda/envs/xc7/bin

symbiflow_synth -t top -v t1.v -d artix7 -p xc7a35tcsg324-1 -x arty.xdc
symbiflow_pack -e top.eblif -d xc7a50t_test
symbiflow_place -e top.eblif -d xc7a50t_test -n top.net -P xc7a35tcsg324-1
symbiflow_route -e top.eblif -d xc7a50t_test
symbiflow_write_fasm -e top.eblif -d xc7a50t_test
symbiflow_write_bitstream -d artix7 -f top.fasm -p xc7a35tcsg324-1 -b top.bit

# openFPGALoader -b arty_a7_35t top.bit

# scp -P 10222 top.bit pi@ps1.fpgas.online:Uploads/t1.bit
# scp -P 10222 t1.py pi@ps1.fpgas.online:Uploads
# ssh -p 10222 pi@ps1.fpgas.online

