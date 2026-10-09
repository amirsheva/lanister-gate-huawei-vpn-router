# Troubleshooting

## Dashboard is down

On the router:

```sh
D=/mnt/jffs2/app/vpn
sh "$D/vpn-ui-start.sh"
ps | grep '[n]c .*8080'
cat "$D/vpn-http.pid" 2>/dev/null
```

## VPN appears connected but a site does not open

Check DNS separately from VPN health.

Example:

```bash
dig +short youtube.com
curl -4 -I --max-time 10 https://www.youtube.com
```

If a public site resolves to a private/unexpected IP, inspect router DNS forwarding and resolver routing.

## Verify Family DNS route

```sh
ip route get 1.1.1.3
ip route get 1.0.0.3
```

When the VPN is healthy, the reference configuration expects `dev tun0`.

## Test DNS self-heal

```sh
ip route del 1.1.1.3/32 2>/dev/null
ip route del 1.0.0.3/32 2>/dev/null
sleep 20
ip route get 1.1.1.3
ip route get 1.0.0.3
```

## Location switching

Inspect:

```bash
curl -s http://192.168.100.1:8080/api/status
curl -s http://192.168.100.1:8080/api/locations
```

Important fields:

```text
status
health_state
default_dev
config_op
active
```

A failed new profile should end in `rollback_ok` with the previous profile active.
