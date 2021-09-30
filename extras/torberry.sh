#!/bin/bash
# Torberry init script
# 2013 alex.a.bravo@gmail.com
# torberry.googlecode.com

if [ "$L1" == "tty1" ]; then
clear
cat /etc/torberry-issue
. /lib/lsb/init-functions
iptables -F
iptables -t nat -F
trap "" 1 2 3 9 15
if [ -f /etc/firstrun ]; then
 echo "Torberry first start!"
 echo "We need to regenerate dropbear host keys. Be patient..."
 service dropbear stop
 rm /etc/dropbear/dropbear_dss_host_key
 rm /etc/dropbear/dropbear_rsa_host_key
 echo "Generating Dropbear RSA key..." 
 dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key -s 1024
 echo "Generating Dropbear DSS key..." 
 dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key -s 1024
 chmod 600 /etc/dropbear/dropbear_dss_host_key
 chmod 600 /etc/dropbear/dropbear_rsa_host_key
 service dropbear start
 rm /etc/firstrun
fi
if [ -f /etc/resizeflag ]; then
 echo "root partition resize requested."
 echo "it will take some time..."
 service ifplugd stop
 service dropbear stop
 resize2fs /dev/root
 rm /etc/resizeflag
 service ifplugd start
 service dropbear start
fi
echo "Torberry is starting..."
log_action_begin_msg "Mounting temp dirs..."
mount -t tmpfs -o size=48M,uid=101,gid=102 tmpfs /var/lib/tor
mount -t tmpfs -o size=6M,uid=101,gid=4 tmpfs /var/log/tor
log_action_end_msg 0
#Common boot ended
echo "Reading torberry.conf"
. /etc/torberry.conf
if [ "$OPERATION_MODE" == "nonphys" ]; then
netmode=1
cat << EOF > /etc/network/interfaces
auto lo

iface lo inet loopback
iface eth0 inet dhcp
EOF
echo "Starting in non-physical isolation mode"
service networking start
service ifplugd start
elif [ "$OPERATION_MODE" == "physical-isolation" ]; then
netmode=2
  if [ "$UPSTREAM_IP_MODE" == "dhcp" ]; then
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto $UPSTREAM_IF
iface $UPSTREAM_IF inet dhcp
EOF
  elif [ "$UPSTREAM_IP_MODE" == "manual" ]; then
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto $UPSTREAM_IF
iface $UPSTREAM_IF inet static
    address $UPSTREAM_IP_IPADDR
    netmask $UPSTREAM_IP_NETMASK
    network $UPSTREAM_IP_NETWORK
    broadcast $UPSTREAM_IP_BROADCAST
    gateway $UPSTREAM_IP_GATEWAY
EOF
  fi
  if [ "$UPSTREAM_WIRELESS" == "true" ]; then
cat << EOF > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=/var/run/wpa_supplicant
network={
        ssid="${UPSTREAM_WL_SSID}"
        proto=$UPSTREAM_WL_PROTO
        key_mgmt=$UPSTREAM_WL_KEYMGMT
        psk=$UPSTREAM_WL_PASSWD
}
EOF
wpa_supplicant -B -Dwext -i${UPSTREAM_IF} -c/etc/wpa_supplicant/wpa_supplicant.conf 2>&1 > /dev/null
  fi
  #Here begins downstream config
  if [ "$DOWNSTREAM_WIRELESS" == "true" ]; then
    echo THIS A PLACEHOLDER FOR A FUTURE FUNCTIONALITY
    echo Currently downstream only allows copper
  fi

cat << EOF >> /etc/network/interfaces

auto $DOWNSTREAM_IF
iface $DOWNSTREAM_IF inet static
   address $DOWNSTREAM_IP_IPADDR
   netmask $DOWNSTREAM_IP_NETMASK
   network $DOWNSTREAM_IP_NETWORK
   broadcast $DOWNSTREAM_IP_BROADCAST
EOF
cat << EOF > /etc/default/isc-dhcp-server
# Defaults for isc-dhcp-server initscript
# sourced by /etc/init.d/isc-dhcp-server
# installed at /etc/default/isc-dhcp-server by the maintainer scripts

#
# This is a POSIX shell fragment
#

# Path to dhcpd's config file (default: /etc/dhcp/dhcpd.conf).
#DHCPD_CONF=/etc/dhcp/dhcpd.conf

# Path to dhcpd's PID file (default: /var/run/dhcpd.pid).
#DHCPD_PID=/var/run/dhcpd.pid

# Additional options to start dhcpd with.
#       Don't use options -cf or -pf here; use DHCPD_CONF/ DHCPD_PID instead
#OPTIONS=""

# On what interfaces should the DHCP server (dhcpd) serve DHCP requests?
#       Separate multiple interfaces with spaces, e.g. "eth0 eth1".
INTERFACES="${DOWNSTREAM_IF}"
EOF
cat << EOF > /etc/dhcp/dhcpd.conf
ddns-update-style none;                                                   
option domain-name "example.org";                                         
option domain-name-servers ns1.example.org, ns2.example.org;              
default-lease-time 600;                                                   
max-lease-time 7200;                                                      
log-facility local7;                                                      
                                                                         
subnet $DOWNSTREAM_IP_NETWORK netmask $DOWNSTREAM_IP_NETMASK {                                
  range $DOWNSTREAM_DHCP_FROM ${DOWNSTREAM_DHCP_TO};                                         
  option domain-name-servers ${DOWNSTREAM_IP_IPADDR};                                 
  option routers ${DOWNSTREAM_IP_IPADDR};                                             
  default-lease-time 600;                                                
  max-lease-time 7200;                                                   
}
EOF
echo "Starting physical isolation mode"
service networking start
service isc-dhcp-server start
fi
log_action_begin_msg "Waiting for a valid IP address..."

if [ $netmode -eq 1 ]; then
IP=$(hostname -I)
while [ -z $IP ]; do
 sleep 2
 IP=$(hostname -I)
 IP=${IP%?}
done
fi
if [ $netmode -eq 2 ]; then
IP=$DOWNSTREAM_IP_IPADDR
fi
log_progress_msg "[ $IP ] "
log_action_end_msg 0
log_action_begin_msg "Setting current date..."
ntpdate $NTPD 2>&1 > /dev/null
log_action_end_msg 0
log_action_begin_msg "Setting iptables rules..."

if [ $netmode -eq 1 ]; then
NETWORK=$(netstat -nr | tail -1 | awk '{print $1 }')
fi
if [ $netmode -eq 2 ]; then
NETWORK=$DOWNSTREAM_IP_NETWORK
fi
NON_TOR=$NETWORK"/24"
TOR_UID="debian-tor"
TRANS_PORT="9040"
INT_IF=$DOWNSTREAM_IF
iptables -t nat -A OUTPUT -o lo -j RETURN
iptables -t nat -A OUTPUT -m owner --uid-owner $TOR_UID -j RETURN
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53
for NET in $NON_TOR; do
 iptables -t nat -A OUTPUT -d $NET -j RETURN
 iptables -t nat -A PREROUTING -i $INT_IF -d $NET -j RETURN
done
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT
iptables -t nat -A PREROUTING -i $INT_IF -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i $INT_IF -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
for NET in $NON_TOR 127.0.0.0/8; do
 iptables -A OUTPUT -d $NET -j ACCEPT
done
iptables -A OUTPUT -m owner --uid-owner $TOR_UID -j ACCEPT
iptables -A OUTPUT -j REJECT
iptables -A OUTPUT -p icmp -j REJECT
iptables -A INPUT -p icmp -j REJECT
log_action_end_msg 0
cp /etc/tor/torrc.orig /etc/tor/torrc
echo "TransPort "$IP":9040" >> /etc/tor/torrc
echo "DNSPort "$IP":53" >> /etc/tor/torrc
echo "SocksPort "$IP":9050" >> /etc/tor/torrc
echo "nameserver 127.0.0.1" > /etc/resolv.conf
if [ "$ONION_ROUTER" == "true" ]; then
  echo "ORPort "$ONION_ROUTER_ORPORT >> /etc/tor/torrc
  echo "DirPort "$ONION_ROUTER_DIRPORT >> /etc/tor/torrc
  echo "Nickname "$ONION_ROUTER_NICKNAME >> /etc/tor/torrc
  echo "ExitPolicy "$ONION_ROUTER_EXITPOLICY >> /etc/tor/torrc
  echo "RelayBandwidthRate "$ONION_ROUTER_BWRATE" KB" >> /etc/tor/torrc
  echo "RelayBandwidthBurst "$ONION_ROUTER_BWBURST" KB" >> /etc/tor/torrc
  echo "MaxOnionsPending "$ONION_ROUTER_MAXONIONPENDING >> /etc/tor/torrc
  echo "MaxAdvertisedBandwidth "$ONION_ROUTER_MAXADBW" KB" >> /etc/tor/torrc
fi
service tor start
log_action_begin_msg "Starting cherrypy webserver..."
PYTHONPATH=/usr/lib/pymodules/python2.7/TorCtl/ cherryd -c /root/web.config -i HttpServer -P /root -d 
log_action_end_msg 0
/usr/lib/pymodules/python2.7/TorCtl/torberry-boot.py
while [ true ]; do
 sleep 1
done 
else
 return 0
fi
