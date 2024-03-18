mkdir fpga
cd fpga
git clone https://github.com/chipsalliance/f4pga-examples  --recurse-submodules
cd f4pga-examples
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda_installer.sh
export F4PGA_INSTALL_DIR=~/opt/f4pga
mkdir -p $F4PGA_INSTALL_DIR
export FPGA_FAM=xc7
bash conda_installer.sh -u -b -p $F4PGA_INSTALL_DIR/$FPGA_FAM/conda;
source "$F4PGA_INSTALL_DIR/$FPGA_FAM/conda/etc/profile.d/conda.sh";
conda env create -f $FPGA_FAM/environment.yml
mkdir -p $F4PGA_INSTALL_DIR/$FPGA_FAM
F4PGA_TIMESTAMP='20220920-124259'
F4PGA_HASH='007d1c1'
for PKG in $F4PGA_PACKAGES; do
  wget -qO- https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${PKG}-${F4PGA_HASH}.tar.xz | tar -xJC $F4PGA_INSTALL_DIR/${FPGA_FAM}
done

scp -r -P 10522 \
    buildroot emulator build/arty_35/top.bit \
    pi@ps1.fpgas.mithis.com:uploads

sudo mv -v uploads/*/* /srv/tftp/
openFPGALoader -b arty uploads/top.bit
