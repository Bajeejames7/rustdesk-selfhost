# Build: self-hosted RustDesk server deployment package (for James's OWN devices)

Goal: let James remotely view/control his OWN Samsung S23 and Windows PC over the internet,
through a RustDesk relay HE controls (private, free, no third-party servers). This is standard
remote-desktop self-hosting — RustDesk keeps its normal on-device consent grant and the active
screen-share indicator. Do NOT add anything that hides the session, removes the indicator, or
captures a screen without the on-device grant. This package is server config + docs only.

## Deliverables (all in this folder)
1. **docker-compose.yml** running the official RustDesk server:
   - `rustdesk/rustdesk-server` hbbs (signal/ID server) and hbbr (relay).
   - Pin a specific recent image tag (not `latest`). Persist data to a `./data` volume so the
     server key (id_ed25519 / id_ed25519.pub) survives restarts.
   - Expose the required ports: 21114/tcp (web/api, hbbs), 21115/tcp, 21116/tcp, 21116/udp,
     21117/tcp (hbbr), 21118/tcp, 21119/tcp. Document what each is for.
   - `restart: unless-stopped`.
2. **setup.md** — plain step-by-step:
   - Prereqs (Docker Desktop on Windows OR Docker on a Linux VPS).
   - `docker compose up -d`, then where to find the generated **public key**
     (`./data/id_ed25519.pub`) — this is what clients need.
   - Two hosting paths, clearly separated:
     a. **Home-hosted behind the MikroTik** — note it only works if the WAN IP is public
        (NOT CGNAT). Include a CGNAT check: compare the router's WAN IP to the "public IP"
        shown at an IP-echo site; if they differ, it's CGNAT and home-hosting won't accept
        inbound — use the VPS path or a mesh VPN instead.
     b. **VPS-hosted** — any small Linux VPS with a public IP; open the same ports in its firewall.
   - A short note on dynamic home IP: use a DDNS hostname so the relay address stays stable.
3. **mikrotik-portforward.rize** (a plain text snippet, NOT executed) — RouterOS commands to
   dst-nat the RustDesk ports (21115-21119 tcp, 21116 udp, 21114 tcp) from WAN to the LAN IP of
   the host machine, plus the matching firewall accept rules. Leave the host LAN IP and WAN
   interface as clearly-marked placeholders for James to fill in.
4. **client-setup.md** — how to point the clients at the relay:
   - RustDesk Android app on the S23 and RustDesk desktop on Windows: Settings → Network →
     ID/Relay server = the relay's host:port (or DDNS name), Key = contents of id_ed25519.pub.
   - How to set an unattended-access permanent password so James can connect to his own device
     without someone tapping accept each time — and state plainly that the screen-share indicator
     still shows while a session is active (that is expected and not removable).
   - A quick connection test.
5. **README.md** — one-paragraph overview + a note that for James's network a **mesh-VPN
   alternative (Tailscale)** avoids all port-forwarding/CGNAT issues: install Tailscale on both
   devices and RustDesk connects directly over the tailnet. Briefly describe that option.

## Constraints
- No secrets, no hardcoded passwords/keys in any file. Pin image versions.
- Do not deploy anything (no server here). Do not touch git.
- Report what you produced and the exact ports/commands in your -o output file.
