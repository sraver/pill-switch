#!/bin/sh

lan=eth0
wan=wlan0

# Clean
iptables -F
iptables -t nat -F

# Enable masquerading on VPN forwarded traffic
iptables -t nat -A POSTROUTING -o $wan -j MASQUERADE

# Default to deny everything
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback traffic (req by pihole webadmin)
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Allow traffic in/out local network (lazy way for 22 and 80)
iptables -A OUTPUT -o $lan -j ACCEPT
iptables -A INPUT -i $lan -j ACCEPT

# Allow DNS requests from host through VPN (req by unbound)
iptables -A OUTPUT -o $wan -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow forwarding established connections
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow forward from local network to VPN
iptables -A FORWARD -i $lan -o $wan -p icmp -j ACCEPT
iptables -A FORWARD -i $lan -o $wan -p udp -j ACCEPT
iptables -A FORWARD -i $lan -o $wan -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i $lan -o $wan -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i $lan -o $wan -p tcp --dport 443 -j ACCEPT