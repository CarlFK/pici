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

firewall_internal_networks: [10.21.0]

pib_network: 10.21.0

conference_name: pib
room_name: catwalk

common_name: mithis.com
subject_alt_names:
  - frontend.ps1.fpgas.mithis.com
  - backend.ps1.fpgas.mithis.com

letsencrypt_account_email: "cfkarsten@gmail.com"
letsencrypt_well_known_dir: /var/www/well-known

streaming_frontend_aliases: []
streaming_frontend_hostname: frontend.ps1.fpgas.mithis.com

streaming:
  frontend:
    data_root: /srv/streaming-frontend
    onsite: frontend.ps1.fpgas.mithis.com
  geoip:
    domain: mithis.com
    rules:
      - continent: [NA, SA, AN]
        target: sfo1
      - continent: [AS, OC]
        target: sgp1
      - target: ams1
  backend:
    server_name: backend.ps1.fpgas.mithis.com
    data_root: /srv/streaming-backend
    rtmp_push_uris:
      - rtmp://frontend.ps1.fpgas.mithis.com/front
    ips:
      - "1.1.1.1"
  rtmp_publishers:
    - 10.21.0.0/24
  method: rtmp
  rooms:
    - minidebconf
  rtmp:
    vaapi: true
  location: rtmp://frontend.ps1.fpgas.mithis.com:1935/stream/{{ room_name }} live=1
  hq_config:
    hls_bandwidth: 2176000
    video_bitrate: 2000  # kbps
    audio_bitrate: 128000  # bps
    keyframe_period: 60  # seconds
    width: 1280
  adaptive:
    video_codec: libx264
    audio_codec: aac
    variants:
  dump: False
  mix_channels: false

skip_unit_test: false
