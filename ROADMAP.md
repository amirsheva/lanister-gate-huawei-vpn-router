# Roadmap

## Active blocker

- [ ] Restore a healthy VPN tunnel (`openvpn-xor` → `tun0` → table `250`)
- [ ] Capture the failing state before restarting services
- [ ] Validate watchdog/failover state transitions
- [ ] Validate the active profile and remote endpoint

## v6.x

- [ ] Validate every VPN location profile end-to-end
- [ ] Publish the sanitized async switch backend used by v6
- [ ] Add profile pre-flight checks before switching
- [ ] Show resolved endpoint and latency in the location picker
- [ ] Add explicit DNS health to switch progress
- [ ] Add robust UI backend availability recovery
- [ ] Add exact Iran/direct traffic accounting
- [ ] Add mobile layout QA
- [ ] Add automated HTML/JS syntax checks

## v7

- [ ] Generic hardware abstraction
- [ ] Multiple WAN/VPN providers
- [ ] Import/export of sanitized settings
- [ ] Device-based routing policies
- [ ] Optional Home Traffic Control UI
- [ ] Router compatibility matrix
