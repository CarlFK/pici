#!/bin/bash
# Ansible Managed

set -euf
set -o pipefail

vt=8
chvt $vt

log() {
	tee -a /dev/tty$vt 2>&1
}

TERM=linux setterm -blank 0 -powersave off | log

cd /root/playbook-repo
while ! git pull; do
	echo "Waiting for for git pull - network interface might be down..." | log
	sleep 1
done

systemctl disable ansible-firstboot.service

set +e
ansible-up 2>&1 | log
status=$?
set -e

if [ $status -eq 0 ]; then
	echo "Ansible done! Rebooting in 1 minute" | log
	shutdown -r +1 "Ansible completed"
else
	echo "Ansible failed" | log
	systemctl status ansible-firstboot.service --no-pager --full | log
fi

chvt $vt
exit $status
