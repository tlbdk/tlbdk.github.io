#!/bin/bash
while true;
do
  echo "update $REPO"
	(cd /data/git/tlbdk.github.io && git pull)
	sleep 10
done
