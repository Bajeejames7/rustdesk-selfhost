# RustDesk server setup

These are instructions for James to run later. Nothing has been deployed by preparing this package. Use only James's own devices, keeping RustDesk's normal consent grants and visible session/screen-share indicator.

## 1. Prerequisites

Use Docker Desktop on Windows with Linux containers and Docker Compose v2, or Docker Engine with the Compose v2 plugin on a small Linux VPS with a public IPv4 address. A home Linux Docker host also works. Keep the server powered on, prevent sleep, and reserve its LAN address if hosting at home. Docker Desktop must be running for Windows hosting. Obtain installers from [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) or [Docker Engine](https://docs.docker.com/engine/install/).

Keep this package together in one directory. The official image is pinned to `rustdesk/rustdesk-server:1.1.15` for both services, a specific published [upstream release](https://github.com/rustdesk/rustdesk-server/releases/tag/1.1.15) and [image tag](https://hub.docker.com/r/rustdesk/rustdesk-server/tags). It is deliberately not `latest`.

## 2A. Home hosting behind the MikroTik

1. Check the MikroTik's WAN IPv4 address using the router UI or `/ip address print`. Compare the address actually assigned to the WAN interface (including a PPPoE interface if applicable) with the public IPv4 shown at [an IP-echo site](https://api4.ipify.org), visited from a device on the same home connection with VPN/proxy disabled.
2. They must match and the WAN address must be publicly routable. If they differ, treat the connection as CGNAT/upstream NAT: this router's port forwards alone will not accept inbound traffic. Use path 2B or the mesh VPN option in README.md. A mismatch can also be an upstream modem doing double NAT, which requires configuring that device too; do not assume a public inbound path exists. Addresses in `100.64.0.0/10`, `10.0.0.0/8`, `172.16.0.0/12`, or `192.168.0.0/16` are not public WAN IPv4 addresses. Matching addresses alone do not prove the ISP permits inbound connections.
3. For a changing home IP, configure a DDNS hostname (for example MikroTik IP Cloud or your existing DDNS provider). Its DNS A record must track the public IPv4. Use that hostname consistently for the server and both clients.
4. Reserve the Docker host's LAN IPv4 address. Review `mikrotik-portforward.rsc`, replace both placeholders, then apply its commands on the router yourself. It forwards TCP `21114-21119` and UDP `21116` without changing port numbers. Follow its rule-order instructions. Do not forward ports to a container's private Docker address.
5. Allow the same ports through the host firewall. On a Windows Docker host, the following are examples for an elevated PowerShell prompt:

   ```powershell
   New-NetFirewallRule -DisplayName 'RustDesk server TCP' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 21114-21119
   New-NetFirewallRule -DisplayName 'RustDesk server UDP' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 21116
   ```

6. Continue to step 3. Test from cellular data: testing your public hostname from the same LAN may require MikroTik hairpin NAT or split DNS, neither of which is included here.

## 2B. VPS hosting

1. Choose a small Linux VPS with a public IPv4 address. Install Docker Engine and Compose v2. Copy this package to a directory on that VPS. Use the VPS's public IPv4 or a DNS A record pointing to it as `RUSTDESK_HOST`.
2. In the provider's firewall/security group, allow inbound TCP `21114-21119` and UDP `21116`. Allow the same set in the operating system firewall and permit return traffic. No MikroTik forwards are needed for this path.
3. If UFW is already your host firewall, these are the exact allow commands:

   ```sh
   sudo ufw allow 21114:21119/tcp
   sudo ufw allow 21116/udp
   ```

   Preserve your SSH access rule before enabling any firewall. These commands do not enable UFW. Docker-published traffic can bypass UFW filtering; use the provider firewall and Docker-aware forwarding rules for actual exposure restrictions.
4. Continue to step 3 on the VPS.

## 3. Start later, on the chosen host

Open a terminal in this package's directory. Set a bare public hostname or IPv4 address, with no scheme or port. Replace the example reserved hostname with your own. Compose requires this variable; set it again in each new shell before Compose commands.

Windows PowerShell:

```powershell
$env:RUSTDESK_HOST = 'rustdesk.example.com'
docker compose config --quiet
docker compose up -d
docker compose ps
docker compose logs --tail=100 hbbs hbbr
Get-Content .\data\id_ed25519.pub
```

Linux shell:

```sh
export RUSTDESK_HOST='rustdesk.example.com'
docker compose config --quiet
docker compose up -d
docker compose ps
docker compose logs --tail=100 hbbs hbbr
cat ./data/id_ed25519.pub
```

Use `sudo` for Docker commands if your installation requires it. Both services bind-mount `./data` at `/root`, so the generated server identity survives container replacement and restart. Wait for startup before reading the key. Copy the full single-line **public** key from `./data/id_ed25519.pub` to both clients. Never share `./data/id_ed25519` (the private key). Keep a protected backup of the entire data directory; do not commit it or put it on a public share. No keys or passwords are shipped in this package.

If startup fails, inspect the logs and firewall/DNS settings before configuring clients. Use `docker compose down` to stop/remove the containers later; it leaves the bind-mounted `./data` directory intact. Follow client-setup.md to connect.

## Exact port map

| Host port | Service | Purpose |
| --- | --- | --- |
| 21114/TCP | hbbs mapping | Pro HTTP API/web console only; OSS has no listener/API here |
| 21115/TCP | hbbs | NAT type test |
| 21116/TCP | hbbs | ID/signaling connections and TCP hole punching |
| 21116/UDP | hbbs | ID registration and heartbeat |
| 21117/TCP | hbbr | Relay traffic |
| 21118/TCP | hbbs | WebSocket signaling for web clients |
| 21119/TCP | hbbr | WebSocket relay for web clients |

All requested ports are published and included in firewall examples. The native Android/Windows clients need TCP 21115-21117 and UDP 21116. Publishing 21114 does not add a Pro service. WebSocket ports are included to meet the requested map; native clients do not need them. If you later use a web client, follow the official reverse-proxy restrictions for those ports because forwarded-IP headers are trusted. See [official port and Docker documentation](https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/).
