#!/bin/sh
VPNDIR=/mnt/jffs2/app/vpn
MODE="$VPNDIR/traffic-counter.mode"
LAN=192.168.100.0/24

fallback() {
    echo estimated > "$MODE"
    exit 1
}

iptables -t mangle -N VPNUI_IRAN_OUT 2>/dev/null
iptables -t mangle -N VPNUI_IRAN_IN 2>/dev/null
iptables -t mangle -F VPNUI_IRAN_OUT 2>/dev/null || fallback
iptables -t mangle -F VPNUI_IRAN_IN 2>/dev/null || fallback

iptables -t mangle -A VPNUI_IRAN_OUT -o ppp258 -j RETURN >/dev/null 2>&1 || fallback
iptables -t mangle -A VPNUI_IRAN_OUT -j RETURN >/dev/null 2>&1 || fallback
iptables -t mangle -A VPNUI_IRAN_IN -j RETURN >/dev/null 2>&1 || fallback

while iptables -t mangle -C FORWARD -i br0 -s "$LAN" -j VPNUI_IRAN_OUT >/dev/null 2>&1; do
    iptables -t mangle -D FORWARD -i br0 -s "$LAN" -j VPNUI_IRAN_OUT >/dev/null 2>&1 || break
done
while iptables -t mangle -C FORWARD -i ppp258 -o br0 -d "$LAN" -j VPNUI_IRAN_IN >/dev/null 2>&1; do
    iptables -t mangle -D FORWARD -i ppp258 -o br0 -d "$LAN" -j VPNUI_IRAN_IN >/dev/null 2>&1 || break
done

iptables -t mangle -I FORWARD 1 -i br0 -s "$LAN" -j VPNUI_IRAN_OUT >/dev/null 2>&1 || fallback
iptables -t mangle -I FORWARD 1 -i ppp258 -o br0 -d "$LAN" -j VPNUI_IRAN_IN >/dev/null 2>&1 || fallback

echo exact > "$MODE"
exit 0
