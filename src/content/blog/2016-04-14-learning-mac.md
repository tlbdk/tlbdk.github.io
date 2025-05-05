---
title:  "Learning to use the Mac and what to fix"
description: "First mac"
pubDate: 2016-04-14 15:11:00 +0200
categories: mac
slug: mac/2016/04/14/learning-mac.html
heroImage: "/blog-placeholder-2.jpg"
---

I recently got my first mac and have been getting used to it, as an Linux and
Windows user, there is a bit of things that are missing, here is what I found
so far:

* Package manager: Brew
* Terminal: iTerm2

Fixing locale when doing SSH:

``` bash
sudo vim /etc/ssh/ssh_config # Comment out SendEnv LANG LC_
```

Installing bash completion:

``` bash
brew install bash-completion
```
