mkdir -p /etc/net/ifaces/ens19
cat > /etc/net/ifaces/ens19/options << 'EOF'
TYPE=eth
BOOTPROTO=static
CONFIG_IPV4=yes
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF

echo "172.16.1.1/28" > /etc/net/ifaces/ens19/ipv4address

mkdir -p /etc/net/ifaces/ens20
cat > /etc/net/ifaces/ens20/options << 'EOF'
TYPE=eth
BOOTPROTO=static
CONFIG_IPV4=yes
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF

echo "172.16.2.1/28" > /etc/net/ifaces/ens20/ipv4address

systemctl restart network && sleep 2
ip -br a  # проверка: все 3 интерфейса должны быть UP
