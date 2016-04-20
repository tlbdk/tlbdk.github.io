---
layout: post
title:  "Nginx OAuth2 proxy with Github and auth_request"
date:   2016-04-14 15:11:00 +0200
categories: nginx oauth2 auth_request
---

1. Create a new project: https://github.com/settings/developers
2. Under `Authorization callback URL` enter the correct url ie `https://tlb.nversion.dk/oauth2/callback`

Download and install:
https://github.com/bitly/oauth2_proxy

Testing:
``` bash
oauth2_proxy -client-id="<Client id>" -client-secret="<Client Secret>" -provider="github" -cookie-secret="<random string>" -ail-domain="*" -upstream file:///dev/null
```

Nginx config file:
``` nginx
location = /oauth2/auth {
    internal;
    proxy_pass http://127.0.0.1:4180;
    proxy_set_header Host $host;
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
}

location = /oauth2/start {
    internal;
    proxy_pass http://127.0.0.1:4180;
    proxy_set_header Host $host;
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
}

location = /oauth2/callback {
    auth_request off;
    proxy_pass http://127.0.0.1:4180;
    proxy_set_header Host $host;
}

location / {
    auth_request /oauth2/auth;
    error_page 401 = /oauth2/start?rd=$uri;
    # First attempt to serve request as file, then
    # as directory, then fall back to displaying a 404.
    try_files $uri $uri/ =404;
}
```

/etc/oauth2_proxy.cfg:
```
client_id = "<Client id>"
client_secret = "<Client Secret>"
provider = "github"
cookie_secret = "<random string>"
email_domains = [
        "*"
]
upstreams = [
        "file:///dev/null"
]
```

/etc/systemd/system/oauth2_proxy.service:
```
# Systemd service file for oauth2_proxy daemon
#

[Unit]
Description=oauth2_proxy daemon service
After=syslog.target network.target

[Service]
# www-data group and user need to be created before using these lines
User=www-data
Group=www-data

ExecStart=/usr/local/bin/oauth2_proxy -config="/etc/oauth2_proxy.cfg"
ExecReload=/bin/kill -HUP $MAINPID

KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
```
