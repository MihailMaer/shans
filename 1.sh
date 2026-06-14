  GNU nano 8.7                                                    1-1.3

#!/bin/bash

IFACE="ens33"
NEWNAME="eth19"

MAC=$(cat /sys/class/net/$IFACE/address)

cat > /etc/systemd/network/10-$IFACE.link <<EOF
[Match]
MACAddress=$MAC

[Link]
Name=$NEWNAME
EOF

echo "Создан .link файл для $IFACE -> $NEWNAME"
echo "Перезагрузите систему для применения"




#!/bin/bash
hostnamectl set-hostname isp.au-team.irpo
echo "Имя задано"
mkdir -p /etc/net/ifaces/ens18
cat > /etc/net/ifaces/ens18/options << 'EOF'
TYPE=eth
BOOTPROTO=dhcp
SYSTEMD_BOOTPROTO=dhcp4
CONFIG_IPV4=yes
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF
echo "Yes 1.2"
echo "Конфиг создан > /etc/net/ifaces/ens18"
systemctl restart network
sleep 3
ping -c 2 -W 3 77.88.8.8 && echo "Интернет работает"
timedatectl set-timezone Asia/Novosibirsk
timedatectl 
echo "yes 1.3"
#!/bin/bash
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
echo "Yes 1.4"
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
echo "Yes 1.5"
systemctl restart network && sleep 2
ip -br a  # проверка: все 3 интерфейса должны быть U

# Включаем forwarding в sysctl
if grep -q "^net.ipv4.ip_forward" /etc/net/sysctl.conf; then
    sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/net/sysctl.conf
else
    echo "net.ipv4.ip_forward = 1" >> /etc/net/sysctl.conf
fi
sysctl -w net.ipv4.ip_forward=1
echo "Yes 1.6"
apt-get update
apt-get install -y iptables
echo "Yes 1.7"
# Чистим на всякий случай
iptables -t nat -F POSTROUTING
# HQ → WAN
iptables -t nat -A POSTROUTING -s 172.16.1.0/28 -o ens18 -j MASQUERADE
# BR → WAN
iptables -t nat -A POSTROUTING -s 172.16.2.0/28 -o ens18 -j MASQUERADE
# Проверить
iptables -t nat -L POSTROUTING -n -v
echo "Yes 1.8"
mkdir -p /etc/sysconfig
iptables-save > /etc/sysconfig/iptables
systemctl enable --now iptables
echo "Yes 1.9"
systemctl restart network
