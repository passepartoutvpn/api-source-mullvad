#!/bin/bash
URL="https://mullvad.net/en/download/config/" # not stateless
TPL="template"
STATIC="static"
TMP="tmp"
SERVERS_SRC="$STATIC/servers.zip"
SERVERS_DST="$TPL/servers.csv"
SAMPLE_CFG="$TMP/mullvad_at.ovpn"
CA="$TPL/ca.crt"

LINES=100000
CA_BEGIN="<ca>"
CA_END="</ca>"
UDP_OTHER_PORTS="53"
TCP_PORTS="80-443"

echo
echo "WARNING: Profiles must be updated manually!"
echo

mkdir -p $TPL
#curl -L $URL >$SERVERS_SRC
rm -rf $TMP
unzip $SERVERS_SRC -d $TMP
mv $TMP/mullvad_config_ios_all/* $TMP
rmdir $TMP/mullvad_config_ios_all

grep -A$LINES $CA_BEGIN $SAMPLE_CFG | grep -B$LINES $CA_END | egrep -v "$CA_BEGIN|$CA_END" >$CA

rm -f $SERVERS_DST
for CFG in `cd $TMP && ls *.ovpn`; do
    ID=`echo $CFG | sed -E "s/^mullvad_([a-z\-]+)\.ovpn$/\1/"`
    ID_COMPS=(${ID//-/ })
    COUNTRY=${ID_COMPS[0]}
    AREA=${ID_COMPS[1]}
    HOST=$ID.mullvad.net
    UDP_PORT=`grep -E "^remote " $TMP/$CFG | sed -E "s/^.* ([0-9]+)$/\1/"`
    echo $ID,$COUNTRY,$AREA,$HOST,$UDP_PORT-$UDP_OTHER_PORTS,$TCP_PORTS >>$SERVERS_DST
done
