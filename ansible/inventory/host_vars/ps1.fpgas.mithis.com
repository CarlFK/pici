eth_local_mac_address: 00:25:90:22:c4:91
eth_local_address: 10.21.0.1
eth_local_netmask: 24

eth_uplink_mac_address: 00:25:90:22:c4:90
eth_uplink_static: true
eth_uplink_static_address: 45.20.162.9
eth_uplink_static_netmask: 26
eth_uplink_static_gateway: 45.20.162.14
eth_uplink_dns_server: 8.8.8.8

dhcp_range: 10.21.0.128,10.21.0.254,6h

firewall_internal_networks: [10.21.0.0/24]

pib_network: 10.21.0

conference_name: pib
room_name: catwalk

common_name: mithis.com
subject_alt_names:
  - frontend.ps1.fpgas.mithis.com
  - backend.ps1.fpgas.mithis.com

streaming_frontend_aliases: []
streaming_frontend_hostname: ps1.fpgas.mithis.com
domain_name: "{{ streaming_frontend_hostname}}"

switch:
    mac: A0:21:B7:AF:4E:05
    oid: iso.3.6.1.4.1.4526.11.16.1.1.1.3.1
