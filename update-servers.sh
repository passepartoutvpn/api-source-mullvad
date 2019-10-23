#!/bin/bash
URL="https://api.mullvad.net/public/relays/v1/"
TPL="template"
SERVERS="$TPL/servers.json"

mkdir -p $TPL
if ! curl -L $URL >$SERVERS; then
    exit
fi
