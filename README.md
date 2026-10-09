# LANister Gate

**Home Network Control Center for Huawei OptiXstar HS8546X6**

LANister Gate is a lightweight, LAN-only control panel and router-side toolkit for a Huawei OptiXstar HS8546X6 running an OpenVPN XOR tunnel with split routing.

The project grew out of a real home-network deployment where:

- international traffic is routed through OpenVPN,
- Iranian prefixes stay on the direct WAN path,
- the VPN is monitored by a watchdog with failover/rollback behavior,
- Family DNS is enforced at the router,
- the management UI is available only on the LAN,
- VPN locations can be switched from a responsive web dashboard.

> **Status:** experimental / reference implementation.  
> The published `ui/index.html` is the actual LANister Gate v6 dashboard. The VPN engine is currently under active diagnosis because the tunnel is not establishing reliably, so the repository does **not** claim end-to-end VPN connectivity yet.  
> Tested on one Huawei OptiXstar HS8546X6 environment. Do not assume compatibility with other firmware builds.

## Highlights

- Responsive Persian/English dashboard
- Light and dark themes
- Local `Kalameh` font support with system-font fallback
- Live VPN vs direct traffic cards
- Vector route visualization
- VPN service and watchdog health cards
- Location picker with real operation progress
- Switch result tracking via backend `config_op`
- Rollback-aware UI
- LAN-only management endpoint
- Split routing using Linux policy routing / table `250`
- Router-side DNS route self-heal
- No cloud dependency for the dashboard itself

## Architecture

```text
LAN clients
   |
   v
Huawei HS8546X6
   |
   +--> Iran prefixes ----------> ppp258 / direct WAN
   |
   +--> International ----------> tun0 / OpenVPN XOR
   |
   +--> DNS Family -------------> protected resolver path
   |
   +--> LANister Gate ----------> 192.168.100.1:8080 (LAN only)
```

See [`docs/architecture.md`](docs/architecture.md) for details.

## Repository layout

```text
.
├── ui/
│   ├── index.html
│   ├── favicon.svg
│   └── assets/fonts/README.md
├── router/
│   ├── install-ui.sh
│   ├── dns-route-ensure.sh
│   ├── api-contract.md
│   └── examples/
├── tools/
│   └── lanister-login.exp.example
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── troubleshooting.md
│   ├── security-notes.md
│   └── screenshots/
├── SECURITY.md
├── ROADMAP.md
└── CHANGELOG.md
```

## Quick install: UI only

The current UI expects the router backend to already expose these endpoints:

```text
GET  /api/status
GET  /api/locations
GET  /api/routing
GET  /api/config
GET  /api/security
GET  /api/logs
POST /api/config/switch
POST /api/action/repair
POST /api/action/restart
POST /api/action/stop
```

Copy `ui/index.html` to the router's LANister Gate directory:

```sh
D=/mnt/jffs2/app/vpn
cp index.html "$D/index.html"
chmod 644 "$D/index.html"
sh "$D/vpn-ui-start.sh"
```

See [`docs/deployment.md`](docs/deployment.md) for the full workflow.

## Fonts

The UI supports local `KalamehWebFaNum` WOFF2 files if you already have a licensed copy.

Font files are **not included in this repository**. Put them under:

```text
/mnt/jffs2/app/vpn/assets/fonts/
```

Expected names:

```text
KalamehWebFaNum-Regular.woff2
KalamehWebFaNum-Medium.woff2
KalamehWebFaNum-SemiBold.woff2
KalamehWebFaNum-Bold.woff2
KalamehWebFaNum-ExtraBold.woff2
```

The dashboard falls back to system fonts when they are absent.

## Security

Never commit:

- `auth.txt`
- real `.ovpn` profiles containing secrets
- `scramble obfuscate ...` secrets
- VPN usernames/passwords
- private keys or certificates
- runtime logs containing sensitive data
- router backup/config dumps

The included `.gitignore` blocks the common sensitive paths.

Read [`SECURITY.md`](SECURITY.md) and [`docs/security-notes.md`](docs/security-notes.md) before publishing.

## Router access helper

`tools/lanister-login.exp.example` shows the macOS Keychain + `expect` approach used for one-command router login:

```bash
lanister
```

The password remains in macOS Keychain instead of being stored in the script.

## Compatibility

Current reference environment:

- Huawei OptiXstar HS8546X6
- BusyBox / ash
- Linux 4.4.x class firmware
- OpenVPN XOR build
- legacy iptables
- policy routing table `250`
- LAN management port `8080`

Other Huawei firmware versions may differ significantly.

## Project goals

LANister Gate is intentionally small and router-friendly. It is not intended to replace OpenWrt, pfSense, OPNsense, or a full SD-WAN stack.

The focus is:

1. clear local visibility,
2. safe VPN switching,
3. automatic recovery,
4. split routing,
5. low resource usage,
6. zero cloud dependency for management.

## Current blocker

The UI/UI-watchdog can be healthy while the VPN engine itself is disconnected. The active investigation checks, in order:

1. whether `openvpn-xor` is running,
2. whether `tun0` is created,
3. whether the active profile and `remote` are valid,
4. whether the VPN watchdog is stuck in failover,
5. whether policy routing table `250` is rebuilt correctly.

See the open GitHub issue for the live troubleshooting checklist.

## License

MIT. See [`LICENSE`](LICENSE).

## Disclaimer

This is an unofficial community project and is not affiliated with Huawei or VPN.AC.
