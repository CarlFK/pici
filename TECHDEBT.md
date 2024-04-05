Things that may come back to haunt me later.

1. onboard eth vs. dongle eth.
In one instance, the dongle got eth0, onboard eth1. result: onboard got both dhcp and static 192.168.1.100
so: udev rules to assign names based on usb port number: eth-uplink, eth-fpga
https://github.com/CarlFK/pici/tree/main/ansible/roles/fixpi/files/etc/systemd/network

2. Power from PoE
maybe the random (1 in 50?) boot problems (boot gets stuck) is because of bad power.
maybe droping the clock will use less power and dodge the problem?
/boot/firmware/config.txt core_freq=250
Still have boot problems, but maybe not as often.  maybe.

3. camera error
on one pi+camera (seems to be tied to the pi, 2nd camera didn't work, all cams work on other pi)
/boot/firmware/config.txt core_freq=250 (or anything under 500)  = camera error
core_freq=500 fixed it.
might bring back the Power PoE problem.  might not have ever been a problem.
