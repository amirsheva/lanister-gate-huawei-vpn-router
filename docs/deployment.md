# Deployment

## 1. Prepare the router directory

Reference path:

```text
/mnt/jffs2/app/vpn
```

## 2. Install the UI

Copy:

```text
ui/index.html
```

to:

```text
/mnt/jffs2/app/vpn/index.html
```

Keep a timestamped backup first.

## 3. Optional local fonts

If licensed, place the Kalameh WOFF2 files in:

```text
/mnt/jffs2/app/vpn/assets/fonts/
```

## 4. Start the UI backend

The reference backend listens on LAN port `8080`.

Confirm:

```sh
ps | grep '[n]c .*8080'
```

## 5. Restrict access

Only permit LAN clients to reach the management port.

Do not expose `8080` on WAN.

## 6. Validate

From a LAN client:

```bash
curl -s http://192.168.100.1:8080/api/status
curl -s http://192.168.100.1:8080/api/locations
```

Then open:

```text
http://192.168.100.1:8080
```
