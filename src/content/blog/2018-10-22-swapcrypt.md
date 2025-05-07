---
title:  "encrypted swap on Ubuntu 18.10"
description: ""
pubDate:   2018-10-22 19:30:00 +0200
categories: FSCrypt
slug: ubuntu/2018/10/22/encrypted-swap.html
heroImage: "/blog-placeholder-2.jpg"
---

Install cryptsetup utils:

Be sure not to install cryptsetup-initramfs as it seems to cause problems booting.

``` bash
sudo apt-get install cryptsetup-run
```

Find and disable current swap device:

``` bash
swapon -s
swapoff -a
```

Give device a label:

``` bash
sudo mkfs.ext2 -L cryptswap /dev/nvme0n1p7 1M
```

/etc/crypttab:

``` text
# <target name>	<source device>		<key file>	<options>
swap      LABEL=cryptswap    /dev/urandom   swap,cipher=aes-xts-plain64,size=256
```

/etc/fstab:

``` bash
...
/dev/mapper/swap none            swap    sw              0       0
```

Start encrypted swap device and add swap:

``` bash
cryptdisks_start swap
swapon -a
```

Remove old swap resume swap UUID:

``` bash
rm -f /etc/initramfs-tools/conf.d/resume
```

Update initiramfs:

``` bash
sudo update-initramfs -u
```