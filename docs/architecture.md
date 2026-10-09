# Architecture

LANister Gate has four logical layers.

## 1. Router networking

- WAN interface: provider PPP interface
- VPN interface: `tun0`
- policy table: `250`
- LAN traffic rule: LAN-origin traffic is evaluated against table `250`
- Iranian prefixes: direct WAN
- default international route: VPN while healthy
- WAN fallback: direct route when the VPN watchdog fails health checks

## 2. VPN service

The router runs an OpenVPN XOR-compatible binary with `route-nopull`.

A separate watchdog checks tunnel health and flips the table-250 default between the VPN and WAN paths.

Location switching is asynchronous and should always keep a last-known-good profile for rollback.

## 3. DNS policy

LAN DNS requests are handled by the router.

The reference environment uses Cloudflare Family resolvers:

```text
1.1.1.3
1.0.0.3
```

The DNS route helper can keep those resolver IPs on the healthy VPN tunnel where needed to avoid upstream DNS manipulation.

## 4. LANister Gate UI

The UI is static HTML/CSS/JavaScript served from the router.

It polls router-local API endpoints and renders:

- VPN state
- exit location
- traffic rates
- route visualization
- service health
- technical diagnostics
- VPN location switch progress

The UI should never be directly exposed to the public Internet.
