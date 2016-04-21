#!/bin/bash
sed -i "s/#{none:GITHUB_CLIENT_ID}/$GITHUB_CLIENT_ID/" /etc/oauth2_proxy.cfg
sed -i "s/#{none:GITHUB_CLIENT_SECRET}/$GITHUB_CLIENT_SECRET/" /etc/oauth2_proxy.cfg
sed -i "s/#{none:GITHUB_COOKIE_SECRET}/$GITHUB_COOKIE_SECRET/" /etc/oauth2_proxy.cfg
unset GITHUB_CLIENT_ID
unset GITHUB_CLIENT_SECRET
unset GITHUB_COOKIE_SECRET

# Load ssh key into agent so we can use it later in the script
eval "$(ssh-agent)" > /dev/null
trap 'ssh-agent -k > /dev/null' EXIT
chmod 600 /root/.ssh/id_rsa
expect << EOF
  spawn ssh-add /root/.ssh/id_rsa
  expect "Enter passphrase"
  send "$SSH_PASSWORD\r"
  expect eof
EOF
unset SSH_PASSWORD

# Cache key
ssh -o StrictHostKeyChecking=no git@github.com

# Do initial close
REPO="git@github.com:tlbdk/tlbdk.github.io.git"
if [ ! -d "$REPO" ]; then
  (cd /data/git && git clone $REPO)
fi

# Run update script in the background
/usr/local/bin/update.sh &  # TODO: Start as fx. www-data

# Clean up enviroment before starting our supervisor services
unset SSH_PASSWORD
unset SSH_AUTH_SOCK
unset SSH_AGENT_PID

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
