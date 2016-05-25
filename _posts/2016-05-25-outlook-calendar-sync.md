---
layout: post
title:  "Sync your outlook calender to a gmail og google apps account"
date:   2016-04-14 15:11:00 +0200
categories: outlook sync gmail googleapps
---

Download and install [Outlook Google Calendar Sync](https://outlookgooglecalendarsync.codeplex.com)

Disable warning of programmatic access in Outlook 2013:

``` ini
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\15.0\Outlook\Security]
"ObjectModelGuard"=dword:00000002

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\15.0\outlook\security]
"adminsecuritymode"=dword:00000003
"promptoomsend"=dword:00000002
```
