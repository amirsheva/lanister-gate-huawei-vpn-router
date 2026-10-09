# LANister Gate backend API contract

The UI is intentionally static and talks to a small router-local HTTP backend.

## Required endpoints

### `GET /api/status`

Expected fields include:

```json
{
  "status": "connected",
  "location": "Germany (de1)",
  "openvpn_pid": "1234",
  "watchdog_pid": "1235",
  "tun_ip": "10.x.x.x",
  "wan_ip": "x.x.x.x",
  "default_dev": "tun0",
  "vpn_rx_bytes": "0",
  "vpn_tx_bytes": "0",
  "wan_rx_bytes": "0",
  "wan_tx_bytes": "0",
  "direct_rx_bytes": "0",
  "direct_tx_bytes": "0",
  "traffic_mode": "estimated",
  "health_state": "healthy",
  "health_target": "1.1.1.1:443",
  "config_op": "idle||0",
  "csrf": "token"
}
```

### `GET /api/locations`

```json
{
  "active": "germany-de1.ovpn",
  "locations": [
    "germany-de1.ovpn",
    "netherlands_amsterdam-1-xor-tcp.ovpn"
  ]
}
```

### `POST /api/config/switch`

Body: exact profile filename.

Header:

```text
X-VPN-CSRF: <token>
Content-Type: text/plain;charset=utf-8
```

Recommended response:

```json
{"ok":true,"code":"switch_started"}
```

HTTP status: `202 Accepted`.

### `config_op`

Recommended state format:

```text
<state>|<value>|<unix_timestamp>
```

States understood by the UI:

```text
idle
applying
starting
success
rollback_ok
failed
rollback_failed
```

The switch UI treats `/api/status` + `/api/locations` as authoritative and does not rely on synthetic button clicks.

## Other endpoints

```text
GET  /api/routing
GET  /api/config
GET  /api/security
GET  /api/logs
POST /api/config/rollback
POST /api/action/repair
POST /api/action/restart
POST /api/action/stop
```
