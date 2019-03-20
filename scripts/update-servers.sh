#!/bin/sh
SAMPLE_CFG="tmp/mullvad_at.ovpn"
CA="certs/ca.pem"
SERVERS="template/servers.csv"
LINES=100000
CA_BEGIN="<ca>"
CA_END="</ca>"
UDP_OTHER_PORTS="53"
TCP_PORTS="80-443"

#mkdir template
#curl -L "https://mullvad.net/en/download/config/" >template/src.zip
#rm -rf tmp
#unzip template/src.zip -d tmp

mkdir certs
grep -A$LINES $CA_BEGIN $SAMPLE_CFG | grep -B$LINES $CA_END | egrep -v "$CA_BEGIN|$CA_END" >$CA

rm $SERVERS
for CFG in `ls tmp/*.ovpn`; do
    ID=`echo $CFG | sed -E "s/^tmp\/mullvad_([a-z\-]+).ovpn$/\1/"`
    COUNTRY=`echo $ID | sed -E "s/^([^\-]+)-.*$/\1/"`
    HOST=$ID.mullvad.net
    UDP_PORT=`grep -E "^remote " $CFG | sed -E "s/^.* ([0-9]+)$/\1/"`
    echo $COUNTRY,$HOST,$UDP_PORT-$UDP_OTHER_PORTS,$TCP_PORTS >>$SERVERS
done

#rm -rf tmp
