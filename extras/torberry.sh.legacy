#!/bin/bash
# Torberry init script
#
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
mount -t tmpfs -o size=6M,uid=101,gid=102 tmpfs /var/lib/tor
mount -t tmpfs -o size=6M,uid=101,gid=4 tmpfs /var/log/tor
log_action_end_msg 0

echo "Checking for interfaces"
intf=$(ls -ltr /proc/sys/net/ipv4/conf | awk '{ print $9 }' | grep -v all | grep -v default | grep -v lo)
echo $intf
for i in $intf; do
 if [ "$i" == "eth0" ]; then
    echo "This is the primary eth0 interface" 
    netmode=1
 fi
 if [ "$i" == "wlan0" ]; then
    echo "Detected second interface presence wlan0, switching to physical isolation config" 
    netmode=2
    physif="wlan0"
 fi 
 if [ "$i" == "eth1" ]; then
    echo "Detected second interface presence eth1, switching to physical isolation config" 
    netmode=2
    physif="eth1"
 fi 
done
if [ $netmode -eq 1 ]; then
  echo "starting non-physical isolation config"
  cp /etc/network/interfaces.1 /etc/network/interfaces
  service networking start
  service ifplugd start
fi
if [ $netmode -eq 2 ]; then
  echo "starting physical isolation config"
  if [ "$physif" == "wlan0" ]; then 
    cp /etc/network/interfaces.2 /etc/network/interfaces
    service networking start
    ifconfig -a
    service isc-dhcp-server start
  fi
  if [ "$physif" == "eth1" ]; then 
    cp /etc/network/interfaces.3 /etc/network/interfaces
    service networking start
    ifconfig -a
    service isc-dhcp-server start
  fi
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
IP="172.26.0.1"
fi
log_progress_msg "[ $IP ] "
log_action_end_msg 0
log_action_begin_msg "Setting current date..."
ntpdate hora.uv.es 2>&1 > /dev/null
log_action_end_msg 0
log_action_begin_msg "Setting iptables rules..."

if [ $netmode -eq 1 ]; then
NETWORK=$(netstat -nr | tail -1 | awk '{print $1 }')
fi
if [ $netmode -eq 2 ]; then
NETWORK="172.26.0.0"
fi
NON_TOR=$NETWORK"/24"
TOR_UID="debian-tor"
TRANS_PORT="9040"
INT_IF="eth0"
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
service tor start
/usr/lib/pymodules/python2.7/TorCtl/torberry-boot.py
while [ true ]; do
 sleep 1
done 
else
 return 0
fi
