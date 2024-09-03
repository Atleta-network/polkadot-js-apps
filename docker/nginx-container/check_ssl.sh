#!/bin/bash

CERT_DIR="/etc/nginx/ssl/live/polkadot-explorer.atleta.network"
FULLCHAIN_PEM="$CERT_DIR/fullchain.pem"
PRIVKEY_PEM="$CERT_DIR/privkey.pem"
MD5SUM_FILE="/tmp/md5sum"

while true; do
  sleep 3600
  if [ "$(md5sum "$FULLCHAIN_PEM" "$PRIVKEY_PEM" | md5sum)" != "$(cat "$MD5SUM_FILE" || echo '')" ]; then
    nginx -s reload
    md5sum "$FULLCHAIN_PEM" "$PRIVKEY_PEM" | md5sum > "$MD5SUM_FILE"
  fi
done
