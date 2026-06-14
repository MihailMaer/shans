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
