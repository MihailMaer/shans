#!/bin/bash

#!/bin/bash
hostnamectl set-hostname br-srv.au-team.irpo
echo "yes 9.1"
mkdir -p /etc/net/ifaces/ens19
cat > /etc/net/ifaces/ens19/options << 'EOF'
TYPE=eth
BOOTPROTO=static
CONFIG_IPV4=yes
DISABLED=no
NM_CONTROLLED=no
SYSTEMD_CONTROLLED=no
EOF

echo "192.168.0.2/28" > /etc/net/ifaces/ens19/ipv4address
echo "default via 192.168.0.1" > /etc/net/ifaces/ens19/ipv4route

cat > /etc/resolv.conf << EOF
search au-team.irpo
nameserver 192.168.100.2
EOF

systemctl restart network && sleep 2
ping -c 2 192.168.0.1
echo "yes 9.2"
timedatectl set-timezone Asia/Novosibirsk
apt-get update
apt-get install -y sudo nano tzdata
echo "yes 9.3"
useradd -m -u 2026 sshuser
echo 'sshuser:P@ssw0rd' | chpasswd
usermod -a -G wheel sshuser
sed -i 's/^#\s*WHEEL_USERS ALL=(ALL:ALL) NOPASSWD: ALL/WHEEL_USERS ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# SSH
sed -i 's/^#\?Port .*/Port 2026/' /etc/openssh/sshd_config
grep -q "^Port 2026" /etc/openssh/sshd_config || echo "Port 2026" >> /etc/openssh/sshd_config
grep -q "^AllowUsers" /etc/openssh/sshd_config || echo "AllowUsers sshuser" >> /etc/openssh/sshd_config
grep -q "^MaxAuthTries" /etc/openssh/sshd_config || echo "MaxAuthTries 2" >> /etc/openssh/sshd_config
echo "Authorized access only" > /etc/openssh/banner
grep -q "^Banner" /etc/openssh/sshd_config || echo "Banner /etc/openssh/banner" >> /etc/openssh/sshd_config

systemctl restart sshd
echo "yes 9.4"