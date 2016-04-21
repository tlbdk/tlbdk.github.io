# Pull base image.
FROM ubuntu:16.04
MAINTAINER tlb@rapanden.dk

ENV TERM linux

# Install Nginx.
RUN \
  sed -i "s/http:\/\/archive/http:\/\/dk.archive/g" /etc/apt/sources.list && \
  apt-get update && \
  apt-get dist-upgrade -y && \
  apt-get install -y nginx wget supervisor openssh-client git expect ruby ruby-dev build-essential && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

RUN \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
  	ln -sf /dev/stderr /var/log/nginx/error.log

RUN gem install jekyll

# Do cleanup, TODO: https://www.dajobe.org/blog/2015/04/18/making-debian-docker-images-smaller/
#RUN \
#  rm -rf /var/lib/apt/lists/*
# TODO: Remove all the build dependencies to reduce image size

RUN \
  mkdir -p /data/www && \
  chown www-data:www-data /data/www && \
  mkdir -p /data/git && \
  chown root:root /data/git

# Install oauth2_proxy
# Using self built version as current version does not seem to support auth_request with nginx
#RUN \
#  wget -O - https://github.com/bitly/oauth2_proxy/releases/download/v2.0.1/oauth2_proxy-2.0.1.linux-amd64.go1.4.2.tar.gz | tar -xz && \
#  mv oauth2_proxy-2.0.1.linux-amd64.go1.4.2/oauth2_proxy /usr/local/bin && \
#  chown root:root /usr/local/bin/oauth2_proxy

# Copy in configuration
COPY etc /etc
COPY usr /usr
COPY root /root

# Define default command
CMD ["/usr/local/bin/start.sh"]

# Expose ports.
EXPOSE 80
