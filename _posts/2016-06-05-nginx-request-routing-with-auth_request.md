---
layout: post
title:  "Nginx request routing with auth_request"
date:   2016-04-14 15:11:00 +0200
categories: nginx routing auth_request
---

I have recently been thinking a bit about how to do pilot testing of new
functionallity in prodution without having downtime. Fx. by marking users in a
JWT token and then sending them to a pilot pool of servers based on that marking
when the request hits the load balancer.

The test server and nginx configuraion below does this by using the auth_request
option to send the decision to an external server. Right now it just does
round-robin, but the nodejs server could easly do the decision based on the
content of a JWT token or looking up in an external database.

```javascript
const http = require('http');

var count = 1;

const auth_server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('X-Pilot', (count++ % 2 > 0) ?  'A' : 'B'); // Do round-robin
  res.end();
});

auth_server.listen(3000, "localhost", () => {
  console.log("Server running at http://localhost:3000");
});

const server1 = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World 1\n');
});

server1.listen(3001, "localhost", () => {
  console.log("Server running at http://localhost:3001");
});

const server2 = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World 2\n');
});

server2.listen(3002, "localhost", () => {
  console.log("Server running at http://localhost:3002");
});
```

``` nginx
upstream auth_upstream {
  server 127.0.0.1:3000;
}

upstream app1_base_upstream {
  server 127.0.0.1:3001;
}

upstream app1_pilotA_upstream {
  server 127.0.0.1:3002;
}

map $xpilot $app1_pool {
  default "app1_base_upstream";
  A "app1_pilotA_upstream";
}

server {
  listen 80;
  server_name www.company.com;

  location / {
    auth_request /_auth;
    auth_request_set $xpilot $upstream_http_x_pilot;
    proxy_pass http://$app1_pool;
    add_header X-Pilot-Pool $app1_pool;
  }

  location /_auth {
    internal;

    proxy_pass_request_body off;
    proxy_pass_request_headers off;
    proxy_set_header Content-Length 0;

    proxy_pass http://$auth_upstream;
  }
}
```
