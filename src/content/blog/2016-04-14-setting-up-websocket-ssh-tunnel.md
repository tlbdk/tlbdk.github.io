---
title:  "Setting up a websocket SSH tunnel"
description: ""
pubDate: 2016-04-14 15:11:00 +0200
categories: websocket ssh tunnel
slug: websocket/ssh/tunnel/2016/04/14/setting-up-websocket-ssh-tunnel.html
heroImage: "/blog-placeholder-2.jpg"
---

# Setting up the server

Install wstunnel:

``` bash
sudo npm -g install wstunnel
```

Create systemd unit file /etc/systemd/system/wstunnel.service:

``` ini
[Service]
ExecStart=/usr/bin/wstunnel -s 8080
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=wstunnel
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
```

Register and start wstunnel:

```
systemctl enable wstunnel
systemctl start wstunnel
```

Setup nginx to forward traffic to wstunnel add file /etc/nginx/sites-available/ssh.example.com:

``` nginx
server {
  listen 80;
  server_name ssh.example.com;

  location /socket {
    auth_basic           "closed site";
    auth_basic_user_file /opt/ssh.example.com.htpasswd;

    proxy_redirect     off;
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
    proxy_buffering off;

    proxy_pass http://127.0.0.1:8080;   # assume wstunsrv runs on port 8080
  }

}

server {
  listen 443 ssl;

  ssl_certificate /etc/letsencrypt/live/ssh.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/ssh.example.com/privkey.pem;

  server_name ssh.example.com;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_dhparam /etc/ssl/certs/dhparam.pem;
  ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_stapling on;
  ssl_stapling_verify on;
  add_header Strict-Transport-Security max-age=15768000;

  location /socket {
    auth_basic           "closed site";
    auth_basic_user_file /opt/ssh.example.com.htpasswd;

    proxy_redirect     off;
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_buffering off;

    proxy_pass http://127.0.0.1:8080;
  }
}
```

Create user for basic authentication:

``` bash
echo -n "user:"" > /opt/ssh.example.com.htpasswd
mkpasswd -m sha-512 >> /opt/ssh.example.com.htpasswd
```

Activate the site:

``` bash
ln -s /etc/nginx/sites-available/ssh.example.com /etc/nginx/sites-enabled/ssh.example.com
```

Restart nginx:

``` bash
systemctl restart nginx
```

# Setting up the tunnel on the client

Listen on local port 2222 and forward traffic to server side localhost port 22 connecting over http:

``` bash
wstunnel -t 2222:localhost:22 ws://user:password@ssh.example.com/socket
```

Listen on local port 2222 and forward traffic to server side localhost port 22 connecting over https:

``` bash
wstunnel -t 2222:localhost:22 wss://user:password@ssh.example.com/socket
```

Same as above, but with http proxy:

``` bash
wstunnel -t 2222:localhost:22 -p http://user:password@proxy.example.com:8080 wss://user:password@ssh.example.com/socket
```

Read more about wstunnel [here](https://www.npmjs.com/package/wstunnel)
