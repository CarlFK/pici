#!/bin/bash -ex

# make sd card to update a pi 4
# 1. update eprom
# 2. set boot order to netboot first

# sd card already has raspios
# sd/bot mounted here:
sd_boot=/media/carl/boot

cache=../../cache
pushd .
cd ${cache}
# git clone https://github.com/raspberrypi/rpi-eeprom
rpi_eeprom=$PWD/rpi-eeprom
popd

$rpi_eeprom/rpi-eeprom-config ${rpi_eeprom}/firmware/stable/pieeprom-2022-04-26.bin --config bootconf.txt --out ${sd_boot}/pieeprom.bin
sha256sum ${sd_boot}/pieeprom.bin | cut -d' ' -f1 > ${sd_boot}/pieeprom.sig

