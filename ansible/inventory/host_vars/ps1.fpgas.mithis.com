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

# pi things
nos:
    - { port:  2, mac: "b8:27:eb:2f:5d:08", sn: 042f5d08 }
    - { port:  3, mac: "dc:a6:32:05:32:45", sn: f1b7bb5a }
    - { port:  5, mac: "b8:27:eb:d4:f1:74", sn: 9ed4f174 }
    - { port:  7, mac: "b8:27:eb:33:51:27", sn: 48335127 }
    - { port:  9, mac: "b8:27:eb:a3:51:b4", sn: 8da351b4 }
    - { port: 11, mac: "b8:27:eb:51:01:df", sn: 265101df }
    - { port: 13, mac: "b8:27:eb:68:fc:e7", sn: f168fce7 }
    - { port: 19, mac: "b8:27:eb:69:79:a0", sn: 426979a0 }
    - { port: 21, mac: "b8:27:eb:5f:de:85", sn: 7d5fde85 }
    - { port: 23, mac: "b8:27:eb:0c:f8:43", sn: 9b0cf843 }
      # - { port: ?, mac: "b8:27:eb:5a:26:5b", sn: 035a265b }

