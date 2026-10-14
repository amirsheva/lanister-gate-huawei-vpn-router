#!/bin/sh
VPNDIR=/mnt/jffs2/app/vpn
MODE="$VPNDIR/traffic-counter.mode"
LIST="$VPNDIR/iran-ipv4.txt"
SET=vpnui_iran_v4
LAN=192.168.100.0/24

fallback() {
    echo estimated > "$MODE"
    exit 0
}

# Huawei's shell does not provide the POSIX "command" builtin reliably.
# Test the actual ipset binary instead.
ipset --version >/dev/null 2>&1 || fallback
[ -s "$LIST" ] || fallback

ipset create "$SET" hash:net family inet hashsize 2048 maxelem 4096 -exist >/dev/null 2>&1 || fallback
ipset flush "$SET" >/dev/null 2>&1 || fallback

while IFS= read -r NET; do
    case "$NET" in ''|'#'*) continue ;; esac
    ipset add "$SET" "$NET" -exist >/dev/null 2>&1 || fallback
done < "$LIST"

iptables -t mangle -N VPNUI_IRAN_OUT 2>/dev/null
iptables -t mangle -N VPNUI_IRAN_IN 2>/dev/null
iptables -t mangle -F VPNUI_IRAN_OUT 2>/dev/null || fallback
iptables -t mangle -F VPNUI_IRAN_IN 2>/dev/null || fallback

# First RETURN rule is the exact Iran byte counter consumed by vpn-http.sh.
iptables -t mangle -A VPNUI_IRAN_OUT -m set --match-set "$SET" dst -j RETURN >/dev/null 2>&1 || fallback
iptables -t mangle -A VPNUI_IRAN_OUT -j RETURN >/dev/null 2>&1 || fallback
iptables -t mangle -A VPNUI_IRAN_IN -m set --match-set "$SET" src -j RETURN >/dev/null 2>&1 || fallback
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
