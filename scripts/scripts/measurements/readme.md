# Setup instructions on Ubuntu

Install the following apt packages:

```
apt install libqmi-utils libqmi-glib-dev libgirepository1.0-dev udhcpc python3-tk xclip
```

Disable the ModemManager service so it doesn't talk to the 5G hat:

```
systemctl stop ModemManager.service
systemctl disable ModemManager.service
systemctl restart NetworkManager.service
```

The modem and oscilloscope interaction requires some additional setup (mainly in order to work without running the scripts as root).

Create `/etc/udev/rules.d/50-qmi-and-handyscope.rules` with the following content:

```
# TiePie Handyscope HS3 access for all users
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0e36", ATTRS{idProduct}=="0009", GROUP="users", MODE="0666"

# Qualcomm 5G Modem access for all users
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1e0e", ATTRS{idProduct}=="9001", GROUP="users", MODE="0666"

# Make the modem use raw_ip mode by default
ACTION=="add", SUBSYSTEM=="net", ATTR{qmi/raw_ip}=="*", ATTR{qmi/raw_ip}="Y"
```

To enable the new udev rules, either reboot or run `sudo udevadm control --reload`.

Running `udhcpc` and `ip` requires root privileges. Configure sudo to allow starting `udhcpc` and `ip` without entering a password:

```
echo "$USER ALL = (root) NOPASSWD: /sbin/udhcpc" | sudo tee /etc/sudoers.d/udhcpc-no-password
echo "$USER ALL = (root) NOPASSWD: /usr/sbin/ip" | sudo tee /etc/sudoers.d/ip-no-password
```

Configure `udhcpc` to leave the DNS and routing configurations unchanged by replacing `/etc/udhcpc/default.script` with the following script:

```
#!/bin/sh
# Busybox udhcpc dispatcher script.
# Copyright (C) 2009 by Axel Beckert.
# Copyright (C) 2014 by Michael Tokarev.
# Copyright (C) 2024 by bjoluc.
#
# Based on the busybox example scripts and the old udhcp source
# package default.* scripts.

case $1 in
    bound|renew)
	# Configure new IP address.
	busybox ifconfig $interface ${mtu:+mtu $mtu} \
	    $ip netmask $subnet ${broadcast:+broadcast $broadcast}
	;;

    deconfig)
	busybox ip link set $interface up
	busybox ip -4 addr flush dev $interface
	busybox ip -4 route flush dev $interface
	;;

    *)
	exit 1
	;;
esac
```
