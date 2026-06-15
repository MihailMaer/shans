echo "192.168.0.1/18" > /etc/net/ifaces/ens33/ipv4address
echo "default via 192.168.0.1" > /etc/net/ifaces/ens33/ipv4route
echo "nameserver 77.88.8.8" > /etc/net/ifaces/ens33/resolv.conf
systemctl restart network
