# Security notes

LANister Gate has intentionally conservative scope.

## Recommended

- keep the management UI LAN-only
- keep API mutation endpoints protected by a CSRF token
- use restrictive file permissions for credential files
- keep a last-known-good VPN configuration for rollback
- validate profile filenames before switching
- keep profile upload size bounded
- validate uploaded profile content
- maintain explicit firewall rules for the management port

## Avoid

- exposing the dashboard on WAN
- storing router/VPN credentials in Git
- modifying bootloader or MTD flash for convenience
- assuming a tunnel interface alone means the VPN is healthy
- considering a location switch successful before route + watchdog health are confirmed
