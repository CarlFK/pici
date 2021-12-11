printf "\nRaspberry Pi FPGA gateway node.\n\n"
cat /sys/firmware/devicetree/base/model
printf "\nSerial Number:"
cut -c "9-" /sys/firmware/devicetree/base/serial-number

