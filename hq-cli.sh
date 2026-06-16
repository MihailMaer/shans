#!/bin/bash

#!/bin/bash
hostnamectl set-hostname hq-cli.au-team.irpo
echo "yes 10.1"
mkdir -p /etc/net/ifaces/ens19
cat > /etc/net/ifaces/ens19/options << 'EOF'
TYPE=eth
BOOTPROTO=dhcp
CONFIG_IPV4=yes
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF

systemctl restart network && sleep 4
ip -br a show ens19        # должен получить адрес из 192.168.200.0/28
cat /etc/resolv.conf       # DHCP должен прописать DNS 192.168.100.2
echo "yes 10.2"
timedatectl set-timezone Asia/Novosibirsk
echo "yes 10.3"
host hq-srv.au-team.irpo     # должен резолвить в 192.168.100.2
ping -c 2 hq-srv.au-team.irpo
ping -c 2 br-srv.au-team.irpo  # через GRE-туннель
echo "yes 10.4"