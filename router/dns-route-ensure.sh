#!/bin/sh

# Reference helper used by the VPN watchdog.
# Keeps Family DNS resolver routes on tun0 only while the VPN is healthy.

VPNDIR=${VPNDIR:-/mnt/jffs2/app/vpn}
HEALTH=$(cut -d'|' -f1 "$VPNDIR/vpn-watchdog.state" 2>/dev/null)

if ip link show tun0 >/dev/null 2>&1 && [ "$HEALTH" = "healthy" ]; then
    ip route replace 1.1.1.3/32 dev tun0 2>/dev/null
    ip route replace 1.0.0.3/32 dev tun0 2>/dev/null
else
    ip route del 1.1.1.3/32 2>/dev/null
    ip route del 1.0.0.3/32 2>/dev/null
fi
