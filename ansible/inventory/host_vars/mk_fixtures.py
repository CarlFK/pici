import json

from pprint import pprint

from ansible.parsing.utils.yaml import from_yaml

base='ps1.fpgas.online'

src = from_yaml( open(f'{base}.yml') )

dst = []
pk=1
for pi in src['switch']['nos']:
    pi['location']=pi['loc']
    del(pi['loc'])
    pi['serial_no']=pi['sn']
    del(pi['sn'])
    pprint(pi)
    dst.append(
            { "model": "pibfpgas.pi",
              "pk": pk,
              "fields": pi }
            )
    pk+=1
    # if pk>4: break


json.dump(dst, open(f'/home/carl/src/tv/pib/pici/ansible/roles/site/files/pib/pibfpgas/fixtures/{base}.json','w'))

"""
[
        {'port': 34, 'mac': 'b8:27:eb:6d:27:f6', 'sn': '7a6d27f6', 'loc': '', 'cable_color': 'white'},

        {'port': 36, 'mac': 'b8:27:eb:86:39:63', 'sn': '80863963', 'loc': '', 'cable_color': 'blue'}, {'port': 40, 'mac': 'e4:5f:01:97:1f:7e', 'sn': '613a4524', 'loc': '', 'cable_color': 'gray'}, {'port': 42, 'mac': 'e4:5f:01:8d:f7:17', 'sn': 'f77b8415', 'model': 'Raspberry_Pi_4_Model_B_Rev_1', 'loc': '', 'cable_color': 'yellow'}, {'port': 46, 'mac': 'e4:5f:01:97:32:d2', 'sn': '8483b266', 'loc': '', 'cable_color': 'gray/white'}, {'port': 48, 'mac': 'e4:5f:01:96:f8:a5', 'sn': 'ce8e3593', 'loc': '', 'cable_color': 'blue'}]

[
  {
    "model": "pibfpgas.pi",
    "pk": 1,
    "fields": {
      "port": 1,
      "mac": "",
      "serial_no": "",
      "location": "",
      "cable_color": ""
    }
  },
"""
