#!/bin/bash

# LAN
: ${LOCAL_IPS:="192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"}

# OpenVPN interfaces where the traffic is fully allowed.
: ${VPN_INTERFACES:="tun+"}

# AirVPN VPN Ips
: ${VPN_HOSTNAMES:=""}

# Exposed Ports
: ${EXPOSED_PORTS:=""}


# enable UFW
ufw enable


# LAN
# If DNS is provided by your home router (i.e. 192,168.1.254) then DNS is allowed also
for ip in $LOCAL_IPS; do
    echo "Allowing LAN Traffic to - $ip"
    ufw allow out to $ip
    ufw allow out to $ip
done


# VPN
for name in $VPN_HOSTNAMES; do
    echo "Allowing Traffic to VPN Hostname -  $name"
    ips=$(host -4 $name| awk {'print $NF'})
    for ip in $ips; do 
        ufw allow out to $ip
    done
done


# OpenVPN tunnel interfaces
for tun in $VPN_INTERFACES; do
    echo "Allowing VPN Interface traffic -  $tun"
    ufw allow out on $tun
done

# Allow Exposed Ports
for port in $EXPOSED_PORTS; do
    echo "Allowing Exposed Port -  $port"
    ufw allow in $port
done


# default reject
ufw default reject outgoing
