#!/bin/bash

while true; do
  sleep 3600
  if [ "$(md5sum /etc/nginx/ssl/live/polkadot-explorer.atleta.network/fullchain.pem \
    /etc/nginx/ssl/live/polkadot-explorer.atleta.network/privkey.pem | md5sum)" != \
    "$(cat /tmp/md5sum || echo '')" ]; then
    nginx -s reload
    md5sum /etc/nginx/ssl/live/polkadot-explorer.atleta.network/fullchain.pem \
    /etc/nginx/ssl/live/polkadot-explorer.atleta.network/privkey.pem | md5sum > /tmp/md5sum
  fi
done
