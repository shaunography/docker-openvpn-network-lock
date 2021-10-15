#!/bin/bash

# OpenVPN Conf
: ${CONFIG:=""}

: ${AUTH:=""}


echo "Configuring Firewall"
/opt/ufw_on.sh

echo "Connecting to $CONFIG VPN"
if [ $AUTH == "userpass" ]; then
    openvpn --config /etc/openvpn/$CONFIG/client.conf --auth-user-pass /etc/openvpn/$CONFIG/userpass.txt
else
    openvpn --config /etc/openvpn/$CONFIG/client.conf
fi
