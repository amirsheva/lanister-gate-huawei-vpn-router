#!/bin/sh
VPNDIR=/mnt/jffs2/app/vpn

i=0
while ! ip link show ppp258 >/dev/null 2>&1; do
    sleep 5
    i=$((i+1))
    [ "$i" -ge 24 ] && exit 1
done

grep -q '^tun ' /proc/modules || insmod /lib/modules/4.4.197/kernel/drivers/net/tun.ko
mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

ip route flush table 250
ip route add 192.168.100.0/24 dev br0 table 250
ip route add 172.16.0.0/16 dev br0 table 250
ip route add default dev ppp258 table 250

while read NET; do
    [ -n "$NET" ] && ip route add "$NET" dev ppp258 table 250
done < "$VPNDIR/iran-ipv4.txt"

ip rule show | grep -q '^10000:' || ip rule add pref 10000 iif br0 from 192.168.100.0/24 lookup 250

iptables -t nat -C POSTROUTING -s 192.168.100.0/24 -o tun0 -j MASQUERADE 2>/dev/null || iptables -t nat -I POSTROUTING 1 -s 192.168.100.0/24 -o tun0 -j MASQUERADE

# Rebuild volatile exact Iran/direct traffic counters after every boot/start.
sh "$VPNDIR/vpn-traffic-init.sh" >/dev/null 2>&1

proc_is() {
    PF="$1"
    NEED="$2"
    [ -s "$PF" ] || return 1
    P="$(cat "$PF" 2>/dev/null)"
    [ -n "$P" ] || return 1
    kill -0 "$P" 2>/dev/null || return 1
    CMD="$(tr '\000' ' ' < "/proc/$P/cmdline" 2>/dev/null)"
    echo "$CMD" | grep -Fq "$NEED"
}

if ! proc_is "$VPNDIR/openvpn.pid" "vpnac-xor-router.ovpn"; then
    rm -f "$VPNDIR/openvpn.pid"
    chown root:service "$VPNDIR/openvpn-xor"
    chmod 4750 "$VPNDIR/openvpn-xor"
    "$VPNDIR/openvpn-xor"       --config "$VPNDIR/vpnac-xor-router.ovpn"       --verb 3       --daemon vpnac-xor       --writepid "$VPNDIR/openvpn.pid"       --log "$VPNDIR/openvpn.log"
    sleep 1
    chmod 0750 "$VPNDIR/openvpn-xor"
fi

if ! proc_is "$VPNDIR/vpn-watchdog.pid" "vpn-watchdog.sh"; then
    rm -f "$VPNDIR/vpn-watchdog.pid"
    busybox start-stop-daemon -S -b -m       -p "$VPNDIR/vpn-watchdog.pid"       -x /bin/sh -- "$VPNDIR/vpn-watchdog.sh"
fi

sh "$VPNDIR/vpn-ui-start.sh" >/dev/null 2>&1

if ! proc_is "$VPNDIR/vpn-ui-watchdog.pid" "vpn-ui-watchdog.sh"; then
    rm -f "$VPNDIR/vpn-ui-watchdog.pid"
    busybox start-stop-daemon -S -b -m       -p "$VPNDIR/vpn-ui-watchdog.pid"       -x /bin/sh -- "$VPNDIR/vpn-ui-watchdog.sh"
fi

exit 0
