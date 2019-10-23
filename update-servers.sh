#!/bin/bash
URL="https://api.mullvad.net/public/relays/v1/"
TPL="template"
SERVERS="$TPL/servers.json"

echo
echo "WARNING: Certs must be updated manually!"
echo

mkdir -p $TPL
if ! curl -L $URL >$SERVERS; then
    exit
fi
