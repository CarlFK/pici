
eth_uplink_mac_address: b8:27:eb:cb:1f:f7
eth_uplink_static: false
eth_uplink_static_address: 198.0.220.197
eth_uplink_dns_server: 8.8.8.8

eth_local_mac_address: 60:38:e0:e3:56:a0
eth_local_address: 10.21.0.1
eth_local_netmask: 24
dhcp_range: 10.21.0.128,10.21.0.254,6h

firewall_internal_networks: [10.21.0.0/24]

pib_network: 10.21.0

user_name: fpgadmin

conference_name: pib
room_name: k207

common_name: mithis.com
subject_alt_names:
  - fpgas.mithis.com
  - k207.fpgas.mithis.com

streaming_frontend_aliases: []
streaming_frontend_hostname: fpgas.mithis.com
domain_name: "{{ streaming_frontend_hostname}}"

# Tim's
# Netgear S3300-52X-PoE+
switch:
    mac: 08:bd:43:6b:bb:e0
    oid: iso.3.6.1.2.1.105.1.1.1.3.1

# pi mac n ports
nos:
    - { port: 34, mac: "b8:27:eb:6d:27:f6", sn: "7a6d27f6" , cable_color: "white" }
    - { port: 36, mac: "b8:27:eb:86:39:63", sn: "80863963" , cable_color: "blue" }
    - { port: 40, mac: "e4:5f:01:97:1f:7e", sn: "613a4524", cable_color: "gray" }
    - { port: 42, mac: "e4:5f:01:8d:f7:17", sn: "f77b8415", cable_color: "yellow" }
    - { port: 44, mac: "dc:a6:32:b4:5e:c9", sn: "329205c6", cable_color: "gray + red" }
    - { port: 46, mac: "e4:5f:01:97:32:d2", sn: "8483b266" , cable_color: "gray/white" }
    - { port: 48, mac: "e4:5f:01:96:f8:a5", sn: "ce8e3593" , cable_color: "blue" }
