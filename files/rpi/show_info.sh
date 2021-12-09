cat /sys/firmware/devicetree/base/model
printf "\n\nSerial Number:"
cut -c "9-" /sys/firmware/devicetree/base/serial-number

