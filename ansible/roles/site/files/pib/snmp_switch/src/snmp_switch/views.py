from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

import json
from pprint import pprint

from pysnmp import hlapi # import usmHMAC384SHA512AuthProtocol, usmNoPrivProtocol
from snmp_switch.utils import snmp_set_state, snmp_status, snmp_toggle

# construct params: a dictionary of parameters
# the source of truth is the swich config page, stored as strings in ansible inventory.
# some of the parameters are python objects.
# so convert strings to python objects.

"""
   ansible inventory will use the strings used by snmpget.py:
   -a AUTH-PROTOCOL      authentication protocol ID (MD5|SHA|SHA224|SHA256|SHA384|SHA512)

   map those strings to pysnmp.hlapi constants:

    usmNoAuthProtocol (default is authKey not given)
    usmHMACMD5AuthProtocol (default if authKey is given)
    usmHMACSHAAuthProtocol
    usmHMAC128SHA224AuthProtocol
    usmHMAC192SHA256AuthProtocol
    usmHMAC256SHA384AuthProtocol
    usmHMAC384SHA512AuthProtocol
"""

authProtocol={
        'NoAuth': hlapi.usmNoAuthProtocol,
        'MD5': hlapi.usmHMACMD5AuthProtocol,
        'SHA': hlapi.usmHMACSHAAuthProtocol,
        'SHA224': hlapi.usmHMAC128SHA224AuthProtocol,
        'SHA256': hlapi.usmHMAC192SHA256AuthProtocol,
        'SHA384': hlapi.usmHMAC256SHA384AuthProtocol,
        'SHA512': hlapi.usmHMAC384SHA512AuthProtocol,
        }[settings.SNMP_SWITCH_AUTH_PROTOCOL]

"""
same for
    snmpget.py
   -x PRIV-PROTOCOL      privacy protocol ID (3DES|AES|AES128|AES192|AES192BLMT|AES256|AES256BLMT|DES)

    usmNoPrivProtocol (default is privhKey not given)
    usmDESPrivProtocol (default if privKey is given)
    usm3DESEDEPrivProtocol
    usmAesCfb128Protocol
    usmAesCfb192Protocol
    usmAesCfb256Protocol
"""

privProtocol = {
        'NoPriv': hlapi.usmNoPrivProtocol,
        '3DES': hlapi.usm3DESEDEPrivProtocol,
        'AES': None,
        'AES128': hlapi.usmAesCfb128Protocol,
        'AES192': hlapi.usmAesCfb192Protocol,
        'AES192BLMT': None,
        'AES256': hlapi.usmAesCfb256Protocol,
        'AES256BLMT': None,
        'DES': hlapi.usmDESPrivProtocol,
        }[settings.SNMP_SWITCH_PRIV_PROTOCOL]


# port is the rj45 port on the 24 or 48 or howmanyever port switch.
# not tcp/udp port.  (which seems to be udp 161)
params = {
        'host':settings.SNMP_SWITCH_HOST,
        'username':settings.SNMP_SWITCH_USERNAME,
        'authkey':settings.SNMP_SWITCH_AUTHKEY,
        'authProtocol': authProtocol,
        'privkey':settings.SNMP_SWITCH_PRIVKEY,
        'privProtocol': privProtocol,
        'oid':settings.SNMP_SWITCH_OID,
        'port': None,
        }

def all_to_str(o):
    return o.__str__()

@csrf_exempt
def toggle(request):
    # turn the port off and on again

    params['port'] = request.POST['port']
    d=snmp_toggle( **params )

    response = HttpResponse(content_type="application/json")
    json.dump(d, response, indent=2, default=all_to_str)

    return response

@csrf_exempt
def toggle_all(request):

    l = []
    for port in range(1,48):

        params['port'] = str(port)
        d=snmp_toggle( **params )
        l.append(d)

    response = HttpResponse(content_type="application/json")
    json.dump(l, response, indent=2, default=all_to_str)

    return response

@csrf_exempt
def off_all(request):

    # 2=off
    # params['state']=2

    l = []
    for port in range(1,49):

        params['port'] = str(port)
        d = snmp_set_state( state=2, **params )
        l.append(d)

    response = HttpResponse(content_type="application/json")
    json.dump(l, response, indent=2, default=all_to_str)

    return response


@csrf_exempt
def status(request):

    params['port'] = request.POST['port']
    d=snmp_status( **params )

    d = {'snmp_status': d, 'raw': d.__str__() }
    response = HttpResponse(content_type="application/json")
    json.dump(d, response, indent=2, default=all_to_str)

    return response
