---
title:  "Consul templates"
description: ""
pubDate:   2016-04-14 15:11:00 +0200
categories: consul templates
slug: consul/templates/2016/04/14/consul-templates.html
heroImage: "/blog-placeholder-2.jpg"
---

Running consul:

``` bash
consul agent -dev -advertise=10.212.5.37 -node "tlbdk" -config-dir ./
```

test.json:

``` json
{"service": {"name": "web", "tags": ["rails"], "port": 80}}
```

``` bash
consul-template -consul 127.0.0.1:8500 -template "nginx.ctmpl:nginx.conf"
```
