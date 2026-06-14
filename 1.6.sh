# Включаем forwarding в sysctl
if grep -q "^net.ipv4.ip_forward" /etc/net/sysctl.conf; then
    sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/net/sysctl.conf
else
    echo "net.ipv4.ip_forward = 1" >> /etc/net/sysctl.conf
fi
sysctl -w net.ipv4.ip_forward=1
echo "Yes"
