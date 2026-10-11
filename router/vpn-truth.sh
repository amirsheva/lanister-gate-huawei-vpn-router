#!/bin/sh
# LANister Gate traffic-truth diagnostic. Read-only; does not change routes or services.
set -u

D=${VPNDIR:-/mnt/jffs2/app/vpn}
LAN_SRC=${LAN_SRC:-192.168.100.10}
LAN_IF=${LAN_IF:-br0}
VPN_DEV=${VPN_DEV:-tun0}
WAN_DEV=${WAN_DEV:-ppp258}
INT_TEST=${INT_TEST:-1.1.1.1}
IR_TEST=${IR_TEST:-2.144.0.1}

ok=0
warn=0
bad=0

emit() {
    level="$1"; key="$2"; value="$3"
    printf '%-5s %-20s %s\n' "$level" "$key" "$value"
    case "$level" in
        PASS) ok=$((ok+1)) ;;
        WARN) warn=$((warn+1)) ;;
        FAIL) bad=$((bad+1)) ;;
    esac
}

pid="$(ps | awk '/[o]penvpn-xor/{print $1; exit}')"
if [ -n "$pid" ]; then emit PASS openvpn "pid=$pid"; else emit FAIL openvpn "not running"; fi

wd="$(ps | awk '/[v]pn-watchdog.sh/{print $1; exit}')"
if [ -n "$wd" ]; then emit PASS watchdog "pid=$wd"; else emit WARN watchdog "not running"; fi

tun_ip="$(ip -4 addr show dev "$VPN_DEV" 2>/dev/null | awk '/inet /{print $2; exit}')"
if [ -n "$tun_ip" ]; then emit PASS tun0 "$tun_ip"; else emit FAIL tun0 "missing"; fi

def="$(ip route show table 250 2>/dev/null | awk '/^default/{print; exit}')"
case "$def" in
    *"dev $VPN_DEV"*) emit PASS table250 "$def" ;;
    *"dev $WAN_DEV"*) emit WARN table250 "$def (direct/failover)" ;;
    *) emit FAIL table250 "${def:-missing default}" ;;
esac

rint="$(ip route get "$INT_TEST" from "$LAN_SRC" iif "$LAN_IF" 2>&1 | head -1)"
case "$rint" in
    *"dev $VPN_DEV"*) emit PASS route_international "$rint" ;;
    *"dev $WAN_DEV"*) emit WARN route_international "$rint (direct)" ;;
    *) emit FAIL route_international "$rint" ;;
esac

rir="$(ip route get "$IR_TEST" from "$LAN_SRC" iif "$LAN_IF" 2>&1 | head -1)"
case "$rir" in
    *"dev $WAN_DEV"*) emit PASS route_iran "$rir" ;;
    *"dev $VPN_DEV"*) emit FAIL route_iran "$rir (Iran is entering VPN)" ;;
    *) emit WARN route_iran "$rir" ;;
esac

nat="$(iptables -t nat -L POSTROUTING -n -v -x 2>/dev/null | awk -v dev="$VPN_DEV" '$3=="MASQUERADE" && $7==dev && $8=="192.168.100.0/24"{print "packets="$1",bytes="$2; exit}')"
if [ -n "$nat" ]; then emit PASS lan_nat "$nat"; else emit FAIL lan_nat "MASQUERADE 192.168.100.0/24 -> $VPN_DEV missing"; fi

mode="$(cat "$D/traffic-counter.mode" 2>/dev/null)"
case "$mode" in
    exact) emit PASS traffic_mode "exact" ;;
    "") emit WARN traffic_mode "not declared" ;;
    *) emit WARN traffic_mode "$mode (do not treat direct split as exact)" ;;
esac

state="$(cat "$D/vpn-watchdog.state" 2>/dev/null)"
case "$state" in
    healthy|*) emit PASS health "$state" ;;
    failover|*) emit WARN health "$state" ;;
    "") emit WARN health "no watchdog state" ;;
    *) emit WARN health "$state" ;;
esac

echo
if [ -z "$pid" ] && [ -z "$tun_ip" ] && echo "$def" | grep -q "dev $WAN_DEV"; then
    echo "VERDICT=STOPPED_OR_DIRECT pass=$ok warn=$warn fail=$bad"
    exit 1
fi
if [ "$bad" -gt 0 ]; then
    echo "VERDICT=DEGRADED pass=$ok warn=$warn fail=$bad"
    exit 2
fi
if [ "$warn" -gt 0 ]; then
    echo "VERDICT=CHECK_WARNINGS pass=$ok warn=$warn fail=$bad"
    exit 1
fi

echo "VERDICT=HEALTHY pass=$ok warn=$warn fail=$bad"
exit 0
