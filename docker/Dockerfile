# Pull base image.
FROM ubuntu:16.04
MAINTAINER tlb@rapanden.dk

ENV TERM linux

# Install Nginx.
RUN \
  apt-get update && \
  apt-get install -y nginx wget supervisor cron && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  	&& ln -sf /dev/stderr /var/log/nginx/error.log

# Install oauth2_proxy
RUN \
  wget -O - https://github.com/bitly/oauth2_proxy/releases/download/v2.0.1/oauth2_proxy-2.0.1.linux-amd64.go1.4.2.tar.gz | tar -xz && \
  mv oauth2_proxy-2.0.1.linux-amd64.go1.4.2/oauth2_proxy /usr/local/bin && \
  chown root:root /usr/local/bin/oauth2_proxy

# Copy in configuration
COPY etc /etc
COPY var /var
COPY usr /usr

# Define default command
CMD ["/usr/local/bin/start.sh"]

# Expose ports.
EXPOSE 80
