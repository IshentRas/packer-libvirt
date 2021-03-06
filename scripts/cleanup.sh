#!/bin/bash -eux

echo "* Cleanup yum cache"
yum -y clean all

echo "* Remove the utmp file"
rm -f /var/run/utmp

echo "* Remove udev rules"
rm -rf /dev/.udev/
rm -f /etc/udev/rules.d/70-persistent-net.rules

echo "* Remove temporary files"
rm -rf /tmp/*
rm -rf /var/tmp/*

echo "* Remove ssh client directories"
rm -rf /home/*/.ssh
rm -rf /root/.ssh

echo "* Remove the PAM data"
rm -rf /var/run/console/*
rm -rf /var/run/faillock/*
rm -rf /var/run/sepermit/*

echo "* Remove the process accounting log files"
if [ -d /var/log/account ]; then
    rm -f /var/log/account/pacct*
    touch /var/log/account/pacct
fi

echo "* Remove the crash data generated by ABRT"
rm -rf /var/spool/abrt/*

echo "* Remove email from the local mail spool directory"
rm -rf /var/spool/mail/*
rm -rf /var/mail/*

echo "* Remove the local machine ID"
if [ -d /etc/machine-id ]; then
    rm -f /etc/machine-id
    touch /etc/machine-id
fi
if [ -d /var/lib/dbus/machine-id ]; then
    rm -f /var/lib/dbus/machine-id
    touch /var/lib/dbus/machine-id
fi

echo "* Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

echo "* Empty log files"
find /var/log -type f | while read f; do echo -ne '' > "$f"; done;

echo "* Remove install log files"
rm -f /root/anaconda-ks.cfg
rm -f /root/anaconda-post.log
rm -f /root/initial-setup-ks.cfg
rm -f /root/install.log
rm -f /root/install.log.syslog

echo "* Cleaning up leftover dhcp leases"
rm -f /var/lib/dhclient/*

echo "* Remove resolv.conf"
> /etc/resolv.conf

echo "* Remove Bash history"
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/*/.bash_history

echo "* Remove YUM UUID"
rm -f /var/lib/yum/uuid

echo "* Remove YUM cache"
find /var/cache/yum/ -type f -exec rm -f {} \;

sleep 10

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync
