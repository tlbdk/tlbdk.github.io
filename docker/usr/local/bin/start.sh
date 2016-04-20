#!/bin/bash
sed -i "s/#{none:GITHUB_CLIENT_ID}/$GITHUB_CLIENT_ID/" /etc/oauth2_proxy.cfg
sed -i "s/#{none:GITHUB_CLIENT_SECRET}/$GITHUB_CLIENT_SECRET/" /etc/oauth2_proxy.cfg
sed -i "s/#{none:GITHUB_COOKIE_SECRET}/$GITHUB_COOKIE_SECRET/" /etc/oauth2_proxy.cfg

unset GITHUB_CLIENT_ID
unset GITHUB_CLIENT_SECRET
unset GITHUB_COOKIE_SECRET

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
