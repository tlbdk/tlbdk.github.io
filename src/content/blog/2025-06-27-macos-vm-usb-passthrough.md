---
title:  "USB Passthrough to VM from ARM MacOS host"
description: "What are the options for using a host USB in a VM on MacOS on ARM"
pubDate:   2025-06-27 08:53:00 +0200
categories: MacOS VM, USB Passthrough, VSCode Server, Remote SSH
slug: astro/2025-06-27-macos-vm-usb-passthrough.html
heroImage: "/google-workspace-api.svg"
---

I'm currently working on a project that requires me to use a USB FD-CAN adapter that is supported on MacOS but not fully, MacOS supports HS CAN but not CAN FD, the CAN adapter works perfectly on Linux with upstream drivers and on Windows with proprietary drivers from the vendor. In the long run I also need to add support for running the software on these platforms so I needed a good solution for passing a USB device through to a VM.

There are a number of VM solution on Mac:

* [Parallels Desktop for Mac Pro Edition](https://www.parallels.com/products/desktop/pro/) (Commercial)
* [Virtual Box](https://www.virtualbox.org/) (Open Source)
* [Docker with usbip](https://docs.docker.com/desktop/features/usbip/)
* [Lima](https://github.com/lima-vm/lima) as WLS like solution for Mac
  * https://github.com/lima-vm/lima/issues/2224 (Lima)


I ended up going with Parallels as the devices I'm using wasn't fully support by usbip in docker and Virtual Box from some reason did not work. It's pretty expensive but works well and also has seamless integration.

To get a good development experience I decided to use VSCode's [Remote SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension so the editor UI was running on the Mac but the actually build tools was running inside a small Ubuntu Server VM.


The project I'm developing is written in Zig and Go so installation of development tools was pretty simple:

Install C/C++ development tools:
``` bash
sudo apt-get install build-essential
```

Install Go:
``` bash
wget https://go.dev/dl/go1.24.4.linux-arm64.tar.gz
tar -xf go1.24.4.linux-arm64.tar.gz
mkdir -p $HOME/tools
mv go $HOME/tools/go
```

Install zig:
``` bash
wget https://ziglang.org/download/0.13.0/zig-linux-aarch64-0.13.0.tar.xz
tar -xf zig-linux-aarch64-0.13.0.tar.xz
mkdir -p $HOME/tools
mv zig-linux-aarch64-0.13.0 /$HOME/tools/zig
```

Add the following to .bashrc:
``` bash
export PATH="$HOME/tools/zig:$PATH"
export PATH="$HOME/tools/go/bin:$PATH"
```

After that was done I just ssh'ed into the VM and checked out the source code and using the Remote SSH extension i opened the checked out folder on the VM in VSCode.