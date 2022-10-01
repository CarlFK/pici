cd /sys/devices/virtual/dmi/id
echo $(cat sys_vendor) $(cat product_version) $(cat product_name)
cd
