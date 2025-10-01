---
title:  "VSCode remote for Windows Development on a MacMini M4"
description: "How to use VSCode remote for Windows Development on a MacMini M4"
pubDate:   2025-10-01 10:07:00 +0200
categories: MacOS VM, UVSCode Server, Remote SSH
slug: astro/2025-06-27-vscode-remote-windows-macmini-m4.html
heroImage: "/parallels-windows-vscode.svg"
---

I need to developer a small commandline tool that uses a Windows library but my main development machine is a MacMini M4, I already have a parallels license so I could just install VSCode and just run it in the Windows VM but in the past the development experience has not been great because of latency, keyboard shortcuts and other differences between MacOS and Windows plus the emulation layer. Some months back I developed the same command line tool on Linux by using VSCode remote and a Linux VM and it worked great. So why not try doing this on windows also.

It's been quite a few years since last time I did windows development and some nice things have been added in the mean time. An official package manager, winget is now default on windows installation so a lot of the clicking can be avoided. VSCode remote uses ssh to access the remote machine so thing to do is install a SSH server, this is supported out of the box on modern windows machines.

Note: Windows OpenSSH server does not support agent forwarding so you need to generate a local ssh key pair if fx. need to use git towards github.com.

## Windows setup

1. Install OpenSSH server as Powershell admin:

``` powershell
Get-WindowsCapability -Online | Where-Object Name -like ‘OpenSSH.Server*’ | Add-WindowsCapability –Online
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
```

2. Add ssh keys to "C:\ProgramData\ssh\administrators_authorized_keys" by opening notepad as administrator and creating the file, rename with move if it add .txt.

3. Add rule to open port 22 for tcp in firewall.

``` powershell
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

4. Install needed tools:

``` powershell
winget install Microsoft.WindowsTerminal
winget install --id Git.Git -e --source winget
winget install -e --id zig.zig
```

5. Install Visual Studio for C++ builds tools:

``` powershell
winget install -e --id Microsoft.VisualStudio.2022.BuildTools
winget install -e --id Microsoft.VisualStudio.2022.Community --override "--quiet --add Microsoft.VisualStudio.Workload.NativeDesktop"
```