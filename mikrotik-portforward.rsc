# RouterOS IPv4 snippet only. NOT executed by creating this file.
# Replace REPLACE_WITH_WAN_INTERFACE with the actual WAN ingress interface
# (e.g. the PPPoE interface when applicable), and REPLACE_WITH_HOST_LAN_IP
# with the Docker host's reserved LAN IPv4 address. Keep the quotes.
# Requires a public WAN IPv4, working routing, and the host firewall allows.
# Review existing rules first. Apply once; repeating adds duplicate rules.
# These are FORWARD accepts for dst-natted traffic, not router INPUT rules.

/ip firewall nat add chain=dstnat in-interface="REPLACE_WITH_WAN_INTERFACE" protocol=tcp dst-port=21114-21119 action=dst-nat to-addresses="REPLACE_WITH_HOST_LAN_IP" comment="James RustDesk TCP dstnat"
/ip firewall nat add chain=dstnat in-interface="REPLACE_WITH_WAN_INTERFACE" protocol=udp dst-port=21116 action=dst-nat to-addresses="REPLACE_WITH_HOST_LAN_IP" comment="James RustDesk UDP dstnat"
/ip firewall nat move [find where comment="James RustDesk TCP dstnat"] 0
/ip firewall nat move [find where comment="James RustDesk UDP dstnat"] 0

/ip firewall filter add chain=forward in-interface="REPLACE_WITH_WAN_INTERFACE" connection-nat-state=dstnat dst-address="REPLACE_WITH_HOST_LAN_IP" protocol=tcp dst-port=21114-21119 action=accept comment="James RustDesk TCP forward"
/ip firewall filter add chain=forward in-interface="REPLACE_WITH_WAN_INTERFACE" connection-nat-state=dstnat dst-address="REPLACE_WITH_HOST_LAN_IP" protocol=udp dst-port=21116 action=accept comment="James RustDesk UDP forward"
/ip firewall filter move [find where comment="James RustDesk TCP forward"] 0
/ip firewall filter move [find where comment="James RustDesk UDP forward"] 0

# Moves place these specific rules before existing drop/conflicting NAT rules.
# Review their placement against your own policy before applying.
# No INPUT accept, router management opening, hairpin NAT or IPv6 rules added.
