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

rm -f $SERVERS
for CFG in `ls tmp/*.ovpn`; do
    ID=`echo $CFG | sed -E "s/^tmp\/mullvad_([a-z\-]+).ovpn$/\1/"`
    ID_COMPS=${ID//-/ }
    COUNTRY=${ID_COMPS[0]}
    AREA=${ID_COMPS[1]}
    HOST=$ID.mullvad.net
    UDP_PORT=`grep -E "^remote " $CFG | sed -E "s/^.* ([0-9]+)$/\1/"`
    echo $ID,$COUNTRY,$AREA,$HOST,$UDP_PORT-$UDP_OTHER_PORTS,$TCP_PORTS >>$SERVERS
done

#rm -rf tmp
