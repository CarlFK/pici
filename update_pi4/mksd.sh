#!/bin/bash -ex

# make sd card to update a pi 4
# 1. update eprom (er... maybe?)
# 2. set boot order to netboot first

# sd card is just a blank fat32 fs (not raspios et all)
# sd/boot mounted here:
# sd_boot=/media/carl/bootfs
sd_boot=/media/carl/boot

# firmware-2711 firmware-2712
firmware_dir=firmware-2711/latest/
# eprom_bin=pieeprom-2023-09-28.bin
eprom_bin=pieeprom-2023-05-11.bin

cache=~/temp/cache
pushd .
cd ${cache}
if [ ! -d "rpi-eeprom" ]; then
  git clone https://github.com/raspberrypi/rpi-eeprom
fi
cd rpi-eeprom
git pull
rpi_eeprom=$PWD
cd ..
wget -N https://github.com/raspberrypi/firmware/raw/master/boot/bootcode.bin
popd

${rpi_eeprom}/rpi-eeprom-config ${rpi_eeprom}/${firmware_dir}/${eprom_bin} --config config.txt --out ${sd_boot}/pieeprom.bin
# sha256sum ${sd_boot}/pieeprom.bin | cut -d' ' -f1 > ${sd_boot}/pieeprom.sig
${rpi_eeprom}/rpi-eeprom-digest -i ${sd_boot}/pieeprom.bin -o ${sd_boot}/pieeprom.sig

cp ${rpi_eeprom}/${firmware_dir}/recovery.bin ${sd_boot}
cp ${rpi_eeprom}/../bootcode.bin ${sd_boot}
cp config.txt ${sd_boot}

