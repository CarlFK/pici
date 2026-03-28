Start with a stock RaspiOS file system (what img2files.sh produced)

### netboot.yml
fiddle with tftp paths because bootcode.bin is dumb and doesn't GET files from where you tell it to
config.txt - um... disable bt and enable serial?
cmdline.txt - root=nfs
etc/fstab / and /boot/firmware nfs

### userconf.yml
set the password and tell everyone
enable sshd
create issue.d dir
display IP, pw and things on console
# get fixed sshswitch

sshd password settings
Generate ssh keys for server user
create .ssh dirs
Generate ssh keys for pi users pi and root
Set authorized key for pi root user
Copy keys to pi pi and root authorized_keys
set perms


### tweeks.yml

remove etc/hostname (makes dhclient use hostname provided by dhcp)

pi etc/hosts

let tio connect to the tty and see pi boot messages
enable /dev/serial0
disable (mask) getty systemd service
 don't let getty mess up boot messages over the serial console
tweeks.yml:    name: serial-getty@ttyAMA0.service

don't resize the root fs
don't manage a swap file

apt remove brltty
brltty greedily grabs serial ports, ftdi_sio loses connection

avoid [FAILED] Failed to start Set console font and keymap.
avoid Wi-Fi is currently blocked by rfkill.
tweeks.yml:# - name: avoid [FAILED] Failed to start Hostname Service.
set pistat_host in /etc/environment
etc overrides
resolve.conf
add time to bash prompt
is server pi
install packages on server
tweeks.yml:    name: "{{ user_name }}"
Git checkout this repo for safer 2 hour onpi



### manage.yml
create scripts dir
install scripts to manage pi states
put the pi boot system into maintenance mode
