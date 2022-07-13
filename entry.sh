#!/bin/bash

: ${TYPE:=""}

# OpenConnect Conf
: ${PROTOCOL:=""}

: ${VPN_HOSTNAMES:=""}

: ${USERNAME:=""}


# OpenVPN Conf
: ${CONFIG:=""}

: ${AUTH:=""}


echo "Configuring Firewall"
/opt/ufw_on.sh

if [ $TYPE == "openconnect" ]; then
	openconnect --protocol=$PROTOCOL $VPN_HOSTNAMES -u $USERNAME
else
	echo "Connecting to $CONFIG VPN"
	if [ $AUTH == "userpass" ]; then
	    openvpn --config /etc/openvpn/$CONFIG/client.conf --auth-user-pass /etc/openvpn/$CONFIG/userpass.txt
	else	
	    openvpn --config /etc/openvpn/$CONFIG/client.conf
	fi
fi
