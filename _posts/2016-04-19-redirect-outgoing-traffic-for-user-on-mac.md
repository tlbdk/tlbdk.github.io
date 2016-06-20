---
layout: post
title:  "Intercept outgoing traffic and send it to local proxy on mac"
date:   2016-04-14 15:11:00 +0200
categories: mac proxy mitmproxy fiddler
---

I was missing "fiddler" like traffic interception on OS X, but luckily you can do
something similar with the pf firewall, it's similar to iptables on
linux and allows for doing transparent proxying, but we a few limits. PF can
only do matching on users and groups and not pids like iptables, so the proxy
has to run under a another user to be able to access the server you are proxying.

First install "man in the middle proxy" to handle the local proxying:

``` bash
brew install mitmproxy
```

Create pf.conf file and enable and load the firewall with "pfctl -evf pf.conf",
note that this will overwrite any firewall rules you already have loaded.

``` bash
# Second redirect now incoming traffic to localhost 8080 for all traffic that matches our host and port filter
rdr on lo0 proto tcp from en0 to <IP to redirect to proxy> port { 80, 443 } -> 127.0.0.1 port 8080
# First route all outgoing traffic from en0 to lo0 that matches our host and port filter and user
pass out on en0 route-to lo0 proto tcp from en0 to <IP to redirect to proxy> port { 80, 443 } keep state user { <user id you are running your browser under> }
```

Allow nobody to run "/sbin/pfctl -s state" as this is used by the mitmproxy:

/etc/sudoers:

``` bash
nobody ALL=(root) NOPASSWD: /sbin/pfctl -s state
```

Run mitmweb once as your own user to create ssl certificates in ".mitmproxy":

```bash
mitmweb
```

Start web interface for the proxy under user nobody:

``` bash
sudo -u nobody mitmweb -T --host
```

Go to <http://localhost:8081/> where the web interface is running:
