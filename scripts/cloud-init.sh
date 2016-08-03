#!/bin/bash -eux

### Install packages
echo "* Installing cloud-init"
yum install -y cloud-init cloud-utils-growpart dracut-modules-growroot

### Setup main configuration
echo "* Installing cloud-init configuration"
cat >/etc/cloud/cloud.cfg <<-'EOF'

users:
 - default
disable_root: 1
ssh_pwauth:   0
locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys:   0
ssh_genkeytypes:  ~
syslog_fix_perms: ~
cloud_init_modules:
 - bootcmd
 - write-files
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh
cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - timezone
 - runcmd
cloud_final_modules:
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - final-message
system_info:
  default_user:
    name: centos
    lock_passwd: true
    gecos: Cloud User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    ssh_authorized_keys:
     - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUwKWFOlicVtYha09f6tkf6j8yRmAxXUP0Rt4f6/tQi8n5cLAJA2ml9PK9PIOBiqhNHyhfJKPJYh9BSPwrUnkvef0bKSacgD6vkqGj89Bmwm2BmMZK374HmAr+O0n8ly5QRsSDx/7+altxoN8fqXxG8y063H98jyNRnWyy9qZ38UTM2TZaQHW4P4PClCffooQ5aZrl7bbrqZsPCEJfIZkOhsy78W147P2RTVkob9QCjTw+tEZT6VUKWEahoCvefeBHcMCmerlqVbvC8IrunxYFsJp5CxNvbH1laMVztDhhv39REYXbdhm9krh63ktBvCZle1bnfrrwIF92jJLnDMPN
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd
# vim:syntax=yaml
EOF

### Setup LVM PV grow
echo "* Installing grow PV configuration"
cat > /etc/cloud/cloud.cfg.d/10_grow.cfg <<EOF
growpart:
  mode: auto
  devices: ['/']
  ignore_growroot_disabled: false
EOF
