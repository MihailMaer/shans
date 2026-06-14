mkdir -p /etc/net/ifaces/ens35
cat > /etc/net/ifaces/ens35/options << 'EOF'
TYPE=eth
BOOTPROTO=static
CONFIG_IPV4=yes
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF

echo "172.16.1.2/28" > /etc/net/ifaces/ens35/ipv4address
echo "default via 172.16.1.1" > /etc/net/ifaces/ens35/ipv4route
echo "Yes 2.2"

cat > /etc/resolv.conf << 'EOF'
nameserver 77.88.8.7
EOF

# Применяем WAN и проверяем интернет
systemctl restart network && sleep 2
ping -c 2 -W 3 77.88.8.8 && echo "Интернет через ISP работает"
echo "Yes 2.3"

mkdir -p /etc/net/ifaces/ens35
cat > /etc/net/ifaces/ens35/options << 'EOF'
TYPE=eth
BOOTPROTO=static
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF
echo "Yes 2.4"

mkdir -p /etc/net/ifaces/ens35.100
cat > /etc/net/ifaces/ens35.100/options << EOF
TYPE=vlan
HOST=ens35
VID=100
BOOTPROTO=static
DISABLED=no
ONBOOT=yes
CONFIG_IPV4=yes
EOF

echo "192.168.100.1/27" > /etc/net/ifaces/ens35.100/ipv4address
echo "vlan100"

mkdir -p /etc/net/ifaces/ens35.200
cat > /etc/net/ifaces/ens35.200/options << EOF
TYPE=vlan
HOST=ens35
VID=200
BOOTPROTO=static
DISABLED=no
ONBOOT=yes
CONFIG_IPV4=yes
EOF

echo "192.168.200.1/28" > /etc/net/ifaces/ens35.200/ipv4address
echo "vlan 200"

mkdir -p /etc/net/ifaces/ens35.999
cat > /etc/net/ifaces/ens35.999/options << EOF
TYPE=vlan
HOST=ens35
VID=999
BOOTPROTO=static
DISABLED=no
ONBOOT=yes
CONFIG_IPV4=yes
EOF

echo "192.168.99.1/29" > /etc/net/ifaces/ens19.999/ipv4address
echo "vlan 999"
systemctl restart network && sleep 2
ip -br a  # все 3 VLAN-интерфейса должны быть UP


grep -q "^net.ipv4.ip_forward" /etc/net/sysctl.conf && \
    sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/net/sysctl.conf || \
    echo "net.ipv4.ip_forward = 1" >> /etc/net/sysctl.conf
sysctl -w net.ipv4.ip_forward=1
echo "Yes 2.8"

apt-get update
apt-get install -y iptables frr dhcp-server sudo nano tzdata
echo "Yes 2.9"

useradd -m net_admin
echo 'net_admin:P@ssw0rd' | chpasswd
usermod -a -G wheel net_admin

# Включить NOPASSWD для группы wheel
sed -i 's/^#\s*WHEEL_USERS ALL=(ALL:ALL) NOPASSWD: ALL/WHEEL_USERS ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Проверка
su - net_admin -c 'sudo whoami'  # должно вернуть: root
echo "Yes 2.11"
