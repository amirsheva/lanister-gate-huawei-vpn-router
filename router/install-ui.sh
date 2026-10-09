#!/bin/sh
set -eu

VPNDIR=${VPNDIR:-/mnt/jffs2/app/vpn}
SOURCE=${1:-./ui/index.html}

[ -s "$SOURCE" ] || {
    echo "UI file not found: $SOURCE"
    exit 1
}

STAMP=$(date +%Y%m%d-%H%M%S 2>/dev/null || echo manual)

mkdir -p "$VPNDIR"
if [ -s "$VPNDIR/index.html" ]; then
    cp "$VPNDIR/index.html" "$VPNDIR/index.html.before-lanister-$STAMP"
fi

cp "$SOURCE" "$VPNDIR/index.html"
chmod 644 "$VPNDIR/index.html"

if [ -x "$VPNDIR/vpn-ui-start.sh" ]; then
    sh "$VPNDIR/vpn-ui-start.sh"
fi

echo "LANister Gate UI installed."
