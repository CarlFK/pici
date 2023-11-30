---
eth_local_mac_address: 00:25:90:22:c4:91
eth_local_address: 10.21.0.1
eth_local_netmask: 24

eth_uplink_mac_address: 00:25:90:22:c4:90
eth_uplink_static: true
eth_uplink_static_address: 76.227.131.147
eth_uplink_static_netmask: 26
eth_uplink_static_gateway: 76.227.131.254
eth_uplink_dns_server: 8.8.8.8

dhcp_range: 10.21.0.128,10.21.0.254,6h

firewall_internal_networks: [10.21.0.0/24]

pib_network: 10.21.0

user_name: videoteam

conference_name: pib
room_name: catwalk

common_name: mithis.com
subject_alt_names:
  - frontend.ps1.fpgas.mithis.com
  - backend.ps1.fpgas.mithis.com

streaming_frontend_aliases: []
streaming_frontend_hostname: ps1.fpgas.mithis.com
domain_name: "{{ streaming_frontend_hostname}}"

certbot_site_name: "{{ streaming_frontend_hostname}}"
certbot_mail_address: carl@NextDayVideo.com

# ./mk_secrets.sh | xclip

# snmpget -v 3 -u  -l authPriv -a MD5 -x DES -A wordpass -X wordpass -c pib \

switch:
    # Netgear #2 GS728TPP mac: "b0:39:56:88:22:4c"

    # HP https://support.hpe.com/hpesc/public/docDisplay?docId=c02596727
    # pethMainPseOperStatus .1.3.6.1.2.1.105.1.3.1.1.3

    # James Netgear:
    mac: "A0:21:B7:AF:4E:05"
    oid: "iso.3.6.1.4.1.4526.11.16.1.1.1.3.1"
    ip: "10.21.0.200"
    SNMP_SWITCH_SECURITY_LEVEL: authNoPriv
    SNMP_SWITCH_AUTH_PROTOCOL: MD5

    SNMP_SWITCH_USERNAME: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              63383862666533343737373438393762653139343765396433613337313137613937376563376365
              3731373831313265366236333735363636353039343331650a633331613164353162616539336462
              39636663346665396536393232653035303930316635613832643634343630396365626531303036
              3839623039616635330a633732316436643439316333393638663731356438643564363661333363
              3033
    SNMP_SWITCH_AUTHKEY: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              31633137643833336561643734396434363831323830653664333133613537356637303237633163
              3235616632306432666363376132303631316664376230300a326535303663653534663862376666
              61333039333965376536323333613739343063346462666138613662626665663537303031323338
              6136636531336565360a663737666136363533613464663964386663646435313833333862663438
              3130
    SNMP_SWITCH_PRIVKEY: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              64313764323765383439303430636230346461396131643134306530383261393163346162626231
              6662366365303034376435313734616631656439333139630a383565376438656464356235666564
              31323365613634333838613064666337643339386536343034326636363464393064626131316463
              3536306136626237620a626166393265373662653438353135653438653261396162303364386466
              6533
    SNMP_SWITCH_PASSPHRASE: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              61656634396333346663653334633337626133613239333936326434663864626336663737666437
              3232366137303233663934373830303634653161386537390a633435343361643437653562643436
              32613834663466613538366132343664613864643430316439656530396566306632343835363532
              3661646231306266310a396235306330356164663636626539613066373639376263613430316235
              3162


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

