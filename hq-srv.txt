#!/bin/bash

#!/bin/bash
hostnamectl set-hostname hq-srv.au-team.irpo
echo "Yes 8.1"
mkdir -p /etc/net/ifaces/ens19
cat > /etc/net/ifaces/ens19/options << 'EOF'
TYPE=eth
BOOTPROTO=static
CONFIG_IPV4=yes
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF

echo "192.168.100.2/27" > /etc/net/ifaces/ens19/ipv4address
echo "default via 192.168.100.1" > /etc/net/ifaces/ens19/ipv4route

# Пока DNS смотрит на yandex (чтобы скачать пакеты)
cat > /etc/resolv.conf << 'EOF'
nameserver 77.88.8.8
EOF

systemctl restart network && sleep 2
ping -c 2 192.168.100.1  # шлюз должен отвечать
ping -c 2 77.88.8.8         # интернет тоже
echo "yes 8.2"
timedatectl set-timezone Asia/Novosibirsk
echo "yes 8.3"
apt-get update
apt-get install -y bind bind-utils sudo nano tzdata
echo "yes 8.4"
cat > /var/lib/bind/etc/options.conf << 'EOF'
options {
    version "unknown";
    directory "/etc/bind/zone";
    listen-on { any; };
    listen-on-v6 { none; };
    recursion yes;
    allow-recursion { any; };
    forwarders { 77.88.8.8; };
    allow-query { any; };
};
EOF
echo "yes 8.5"
cat >> /var/lib/bind/etc/rfc1912.conf << 'EOF'
zone "au-team.irpo" { type master; file "au-team.irpo"; };
zone "100.168.192.in-addr.arpa" { type master; file "100.168.192.in-addr.arpa"; };
zone "200.168.192.in-addr.arpa" { type master; file "200.168.192.in-addr.arpa"; };
EOF

# Копируем пустой шаблон как основу
cp /var/lib/bind/etc/zone/empty /var/lib/bind/etc/zone/au-team.irpo
cp /var/lib/bind/etc/zone/empty /var/lib/bind/etc/zone/100.168.192.in-addr.arpa
cp /var/lib/bind/etc/zone/empty /var/lib/bind/etc/zone/200.168.192.in-addr.arpa
echo "yes 8.6"
cat > /var/lib/bind/etc/zone/au-team.irpo << 'EOF'
$TTL 1D
@ IN SOA  au-team.irpo. root.au-team.irpo. ( 2026042100 12H 1H 1W 1H )
  IN NS   au-team.irpo.
  IN A    192.168.100.2

hq-srv   IN A  192.168.100.2
hq-cli   IN A  192.168.200.2
hq-rtr   IN A  192.168.100.1
hq-rtr   IN A  192.168.200.1
hq-rtr   IN A  192.168.99.1
br-rtr   IN A  192.168.0.1
br-srv   IN A  192.168.0.2
isp      IN A  172.16.1.1
EOF
echo "yes 8.7"
cat > /var/lib/bind/etc/zone/100.168.192.in-addr.arpa << 'EOF'
$TTL 1D
@ IN SOA au-team.irpo. root.au-team.irpo. ( 2026042100 12H 1H 1W 1H )
  IN NS  au-team.irpo.
1 IN PTR hq-rtr.au-team.irpo.
2 IN PTR hq-srv.au-team.irpo.
EOF

cat > /var/lib/bind/etc/zone/200.168.192.in-addr.arpa << 'EOF'
$TTL 1D
@ IN SOA au-team.irpo. root.au-team.irpo. ( 2026042100 12H 1H 1W 1H )
  IN NS  au-team.irpo.
1 IN PTR hq-rtr.au-team.irpo.
2 IN PTR hq-cli.au-team.irpo.
EOF
echo "yes 8.8"
rndc-confgen > /var/lib/bind/etc/rndc.key && sed -i '6,$d' /var/lib/bind/etc/rndc.key
chown -R root:named /var/lib/bind/etc/zone/*

named-checkconf && named-checkconf -z   # синтаксис + зоны
systemctl enable --now bind

# Переключаем resolv.conf на себя
cat > /etc/resolv.conf << EOF
search au-team.irpo
nameserver 192.168.100.2
EOF

# Проверка
host hq-rtr.au-team.irpo
host 192.168.100.2
echo "yes 8.9"
useradd -m -u 2026 sshuser
echo 'sshuser:P@ssw0rd' | chpasswd
usermod -a -G wheel sshuser

sed -i 's/^#\s*WHEEL_USERS ALL=(ALL:ALL) NOPASSWD: ALL/WHEEL_USERS ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

id sshuser  # UID должен быть 2026
echo "yes 8.10"
# Порт
sed -i 's/^#\?Port .*/Port 2026/' /etc/openssh/sshd_config
grep -q "^Port 2026" /etc/openssh/sshd_config || echo "Port 2026" >> /etc/openssh/sshd_config

# Только sshuser
grep -q "^AllowUsers" /etc/openssh/sshd_config || echo "AllowUsers sshuser" >> /etc/openssh/sshd_config

# Максимум 2 попытки
grep -q "^MaxAuthTries" /etc/openssh/sshd_config || echo "MaxAuthTries 2" >> /etc/openssh/sshd_config

# Баннер
echo "Authorized access only" > /etc/openssh/banner
grep -q "^Banner" /etc/openssh/sshd_config || echo "Banner /etc/openssh/banner" >> /etc/openssh/sshd_config

systemctl restart sshd
ss -tlnp | grep 2026  # sshd должен слушать на 2026
echo "yes 8.11"