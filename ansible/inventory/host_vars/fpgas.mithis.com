
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

# Netgear S3300-52X-PoE+
# swichip=10.21.0.171  # Tim's
switch:
    mac: ??
    oid: iso.3.6.1.2.1.105.1.1.1.3.1


