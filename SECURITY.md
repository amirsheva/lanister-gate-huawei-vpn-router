# Security Policy

LANister Gate is designed for **LAN-only management**.

## Do not expose the UI to the public Internet

The reference deployment binds the dashboard on a local router port and relies on firewall rules to limit access to the LAN.

## Never publish secrets

Before pushing a repository, verify that none of the following are present:

- VPN username/password files
- `scramble obfuscate` secrets
- private keys
- client certificates
- complete production `.ovpn` files
- router configuration backups
- device serial numbers or administrative passwords
- logs containing credentials or session tokens

Recommended pre-push checks:

```bash
git grep -nEi 'password|passwd|auth-user-pass|scramble|private key|BEGIN .*PRIVATE'
git status --ignored
```

## Router safety

Do not modify bootloader, MTD partitions, firmware images, or persistent flash layout merely to install LANister Gate.

Use writable user/application storage and keep a rollback copy of every changed file.

## Vulnerability reports

Do not open a public issue containing credentials, private network dumps, or VPN secrets.
