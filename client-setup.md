# Connect James's S23 and Windows PC

Install the official RustDesk Android app on the Samsung S23 and the official Windows desktop app from [RustDesk](https://rustdesk.com/docs/en/client/). Use only James's own devices. The server provides ID/signaling and relay services; clients still enforce authentication, permissions, and the normal visible session indicator.

## Configure both clients

1. Open Settings > Network > ID/Relay server on Windows (unlock network settings if prompted). On Android, use Settings > ID/Relay Server; some releases group this under Network.
2. Enter the same values on both devices, replacing `rustdesk.example.com` with your server's public IP or DDNS name:

   | Field | Value |
   | --- | --- |
   | ID Server | `rustdesk.example.com:21116` |
   | Relay Server | `rustdesk.example.com:21117` |
   | API Server | Leave blank (this is OSS) |
   | Key | Full contents of `./data/id_ed25519.pub` |

3. Save and wait for each client to show ready/connected to the ID server. A public key is required for this package. Never paste the private key. Hostnames without ports use the default ports above. Do not put the relay port 21117 in the ID Server field. Both fields must use your own server, avoiding the public RustDesk signaling/relay service.

See [official Android settings](https://rustdesk.com/docs/en/client/android/) and [client configuration](https://rustdesk.com/docs/en/self-host/client-configuration/).

## Password access and required local grants

On each device that James will control, open Settings > Security (unlock settings if requested), choose Set permanent password, and create a unique strong password locally. Enable password acceptance / use permanent password if that choice is present. UI labels vary by release. Store it in your password manager; put no password in these files. On Windows, use RustDesk's normal Install/Start service option if access after reboot or at the login screen is needed, and approve the local Windows prompt.

A permanent password lets James authenticate without another person tapping Accept for each connection when the device's sharing service and required permissions are already active. It does **not** bypass Android's screen-capture consent. On the S23, open RustDesk's screen-sharing/service page, enable the requested screen-capture permission using Samsung/Android's normal Start now/share prompt, and enable Input Control through Accessibility if remote control is wanted. Grant only the permissions needed. Android may require a fresh on-device screen-capture grant after restarting the app/service, rebooting, or ending capture; permanent-password access cannot guarantee fully unattended Android capture.

The normal screen-share/session indicator **still shows while a session is active**. That is expected and not removable in this setup. Keep all normal consent prompts and indicators; no hiding, suppressed notifications, consent bypass, or capture without the on-device grant is included. James can stop screen sharing from the device's normal controls.

## Quick connection test

1. Start the chosen server as described in setup.md and confirm both clients are ready. On the S23, start sharing with the local grant above.
2. Turn off Wi-Fi on the S23 and use cellular data. From Windows, enter the S23's RustDesk ID and connect using its permanent password (or the ordinary local Accept prompt). Confirm the normal indicator is visible on the S23 and screen sharing/control works. Stop the session normally.
3. From the S23, connect to the Windows RustDesk ID and authenticate. Confirm the Windows session UI/indicator remains visible and input works; disconnect normally.
4. To verify the controlled relay path, enable RustDesk's normal Always connect via relay option on the initiating client, reconnect, and check that session information reports Relay. Inspect `docker compose logs --tail=100 hbbr` on the host as supporting evidence; log verbosity varies. Restore the connection preference if direct peer connections are preferred.
5. If it fails, check the exact public key, the separate ID/relay ports, DNS A record, CGNAT, server status, and both router/provider and host firewalls. A same-LAN public-hostname failure can be NAT loopback; repeat over cellular before changing settings. A connection waiting for screen-capture permission requires the on-device Android grant.
