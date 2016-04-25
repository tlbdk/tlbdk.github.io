---
layout: post
title:  "Private github pages hosted in Docker"
date:   2016-04-14 15:11:00 +0200
categories: nginx oauth2 auth_request jekyll
---

A couple of days ago I [posted]({% post_url 2016-04-20-nginx-oauth2-with-githhub %})
about using oauth2_proxy with Nginx to restrict access to github uses. Next
step is move the code to a docker image and a do a github fetch and jekyll build
to finish the setup.

You can find the docker build files [here](https://github.com/tlbdk/tlbdk.github.io/tree/master/docker).

Just to understand the process:

1. Startup image and do initial clone of documentation site with deploy key
2. Startup jekyll build -watch on checked out git repo
2. Do git pull every 10 seconds

# How to use the docker build file

To do you own setup you need to generate a ssh-key pair and put it in the
root/.ssh folder.

``` bash
cd root/.ssh
ssh-keygen # pick location ./id_rsa
```

This key public part needs to be registered in repo Setting -> Deploy keys. I
picked a very long random string for the ssh password, fx. min 40 chars to make
brute-forcing close to impossible.  

Next create a file to hold the enviroment variables, this file should NOT go in
the repo and should be kept private on the hosting server.

Dockerfile.config:

``` ini
GITHUB_CLIENT_ID=<Client id>
GITHUB_CLIENT_SECRET=<Client secret>
GITHUB_COOKIE_SECRET=<Random string>
SSH_PASSWORD=<Password for ssh key>
```

Sample command to build and run the site:

``` bash
cd docker/
docker build -t tlb:tlb.nversion.dk . && docker run --env-file=Dockerfile.config -t -i -p 4280:80 tlb:tlb.nversion.dk
```

Im using Nginx to do the SSL termination, but if you are hosting on AWS then
using Elastic Load Balancer would be the best choice for this:

``` nginx
location / {
  proxy_pass http://127.0.0.1:4280;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_connect_timeout 1;
  proxy_send_timeout 30;
  proxy_read_timeout 30;
}
```
