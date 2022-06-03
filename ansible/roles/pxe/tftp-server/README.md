# tftp-server

Install and manage the TFTP server.

## Tasks

Tasks are separated in two different parts:

* `tasks/d-i.yml` manages the d-i preesed options for the PXE boot.

* `tasks/webserver.yml` configures nginx to server the PXE files.

## Available variables

Main variables are:

* `time_zone`:             The timezone of your machine.

* `domain`:                The DHCP domain.

* `apt_proxy`:             Boolean. If true, d-i will use the configured apt
                           proxy for the installation.

* `debian_host`:           Hostname of the Debian mirror.

* `debian_suites`:         List of Debian suites to offer for install.

* `ubuntu_host`:           Hostname of the Ubuntu mirror.

* `ubuntu_suites`:         List of Ubuntu suites to offer for install.

* `archs`:                 List of archs to offer for install.

* `user_name`:             The username d-i will use during the installation.

* `user_password`:         Main user password in plain text. Please use ansible
                           vault to store this variable.

* `playbook_repo`:         Full URL of the ansible git repository to use as late
                           command after the installation.

* `playbook_branch`:       Branch of said git repository to use.

* `inventory_repo`:        Full URL of the ansible inventory to use.

* `inventory_repo_dir`:    Directory in said git repository to use.

* `pxe_timeout`:           Seconds to wait on the PXE boot menu (see
                           Grub docs for details).
* `vault_pw`:              Ansible vault password (if necessary).

Other variables used are:

* `skip_unit_test`:  Used internally by the test suite to disable actions that
                     can't be performed in the gitlab-ci test runner.
