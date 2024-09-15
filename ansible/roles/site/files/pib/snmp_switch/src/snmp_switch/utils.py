import argparse
import asyncio
import sys
import os

from pprint import pprint
from time import sleep

from pysnmp import hlapi
from pysnmp.proto import rfc1902
from pysnmp.smi.rfc1902 import ObjectIdentity, ObjectType

from pysnmp.hlapi import asyncio as hlapi3
from pysnmp.hlapi.v3arch import asyncio as terhl # terrible hack

class hlapic:
    usmNoAuthProtocol = terhl.USM_AUTH_NONE
    usmHMACMD5AuthProtocol = terhl.USM_AUTH_HMAC96_MD5
    usmHMACSHAAuthProtocol = terhl.USM_AUTH_HMAC96_SHA
    usmHMAC128SHA224AuthProtocol = terhl.USM_AUTH_HMAC128_SHA224
    usmHMAC192SHA256AuthProtocol = terhl.USM_AUTH_HMAC192_SHA256
    usmHMAC256SHA384AuthProtocol = terhl.USM_AUTH_HMAC256_SHA384
    usmHMAC384SHA512AuthProtocol = terhl.USM_AUTH_HMAC384_SHA512
    usmNoPrivProtocol = terhl.USM_PRIV_NONE
    usm3DESEDEPrivProtocol = terhl.USM_PRIV_CBC168_3DES
    #'AES': None,
    usmAesCfb128Protocol = terhl.USM_PRIV_CFB128_AES
    usmAesCfb192Protocol = terhl.USM_PRIV_CFB192_AES
    #'AES192BLMT': None,
    usmAesCfb256Protocol = terhl.USM_PRIV_CFB256_AES
    #'AES256BLMT': None,
    usmDESPrivProtocol = terhl.USM_PRIV_CBC56_DES

# so we can send the browser a message when the power goes off and on:
# tangle up this code with the django-connect web socket code :(
##from channels.layers import get_channel_layer
##from asgiref.sync import async_to_sync


def mk_params():
    # construct params: a dictionary of parameters
    # everything except the switch port number

    # the keys are the parameter names used by
    # snmp_get_state(), snmp_set_state(),
    # which follows hlapi.UsmUserData, etc.

    # The source of truth is the swich config page,
    # copied to strings in ansible inventory.
    # the protocol deails get mapped to pysnmp.hlapi constants
    # and what physical ports are used.

    # put all the snmp parameters in params dict and return it
    params = {}

    # get local switch settings and secrets from env vars
    for k in (
        'host',
        'username',
        'authKey',
        'privKey',
        'oid',
        ):
            ev_name = f'SNMP_SWITCH_{k.upper()}'
            ev_val = os.environ.get(ev_name)
            # print(f"{ev_name=} {ev_val=}")
            params[k] = ev_val

    # these protocol deails get mapped to pysnmp.hlapi constants:
    # authProtocol, privProtocol

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

    k = os.environ.get('SNMP_SWITCH_AUTH_PROTOCOL')
    params['authProtocol'] = {
        'NoAuth': hlapic.usmNoAuthProtocol,
        'MD5': hlapic.usmHMACMD5AuthProtocol,
        'SHA': hlapic.usmHMACSHAAuthProtocol,
        'SHA224': hlapic.usmHMAC128SHA224AuthProtocol,
        'SHA256': hlapic.usmHMAC192SHA256AuthProtocol,
        'SHA384': hlapic.usmHMAC256SHA384AuthProtocol,
        'SHA512': hlapic.usmHMAC384SHA512AuthProtocol,
        }[k]

    """
    same for
   -x PRIV-PROTOCOL      privacy protocol ID (3DES|AES|AES128|AES192|AES192BLMT|AES256|AES256BLMT|DES)

    usmNoPrivProtocol (default if privKey not given)
    usmDESPrivProtocol (default if privKey is given)
    usm3DESEDEPrivProtocol
    usmAesCfb128Protocol
    usmAesCfb192Protocol
    usmAesCfb256Protocol
    """

    k = os.environ.get('SNMP_SWITCH_PRIV_PROTOCOL')
    params['privProtocol'] = {
        'NoPriv': hlapic.usmNoPrivProtocol,
        '3DES': hlapic.usm3DESEDEPrivProtocol,
        'AES': None,
        'AES128': hlapic.usmAesCfb128Protocol,
        'AES192': hlapic.usmAesCfb192Protocol,
        'AES192BLMT': None,
        'AES256': hlapic.usmAesCfb256Protocol,
        'AES256BLMT': None,
        'DES': hlapic.usmDESPrivProtocol,
        }[k]

    # port is the rj45 port on the 24 or 48 or howmanyever port switch.
    # not tcp/udp port.  (which seems to be udp 161)
    # it is set here just to document it.
    params['port'] = None

    return params

def transform_ret(o):
    """
    Extract the interesting info out of what we get from snmp
    """

    try:
        v = o['varBinds']
        v0=v[0]
        i = v0[1]
        ret = i
        # import code; code.interact(local=locals())
    except Exception as e:
        print(e)
        ret = None

    return ret

def notify_dcws(port,state):

    # send message to browser via web socket

    pi_name=f"pi{port}"
    group = f"pistat_{pi_name}"
    message_type="stat.message"
    message_text=f"snmp: power {state}"
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, {"type": message_type, "message": message_text} )


def snmp_set_state(host, username, authKey, privKey, oid, port, state,
        authProtocol, privProtocol):

    """
    state:
        1=on
        2=off
    """

    connectto = hlapi.UdpTransportTarget((host, 161))
    obj_id = ObjectIdentity(oid + '.' + port)

    obj_state = ObjectType(obj_id, rfc1902.Integer(state))

    auth = hlapi.UsmUserData(
        userName=username,
        authKey=authKey,
        authProtocol=authProtocol, #usmHMACSHAAuthProtocol,
        privKey=privKey,
        privProtocol=privProtocol #usmAesCfb256Protocol
    )

    engine = hlapi.SnmpEngine()

    iterator = hlapi.setCmd(
        engine,
        auth,
        connectto,
        hlapi.ContextData(),
        obj_state
    )
    errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

    try:
        v0 = varBinds[0]
        i = v0[1]
        state={1:'on',2:'off'}[i]
    except Exception as e:
        print(e)
        state = None

    ###notify_dcws(port,state)

    ret = {
            'errorIndication': errorIndication,
            'errorStatus': errorStatus,
            'errorIndex': errorIndex,
            'varBinds': varBinds,
            'state': state,
    }

    return ret


async def snmp_status(host, username, authKey, privKey, oid, port,
        authProtocol, privProtocol):

    #connectto = hlapi.UdpTransportTarget((host, 161))
    connectto = await hlapi3.UdpTransportTarget.create((host, 161))
    obj_id = ObjectIdentity(oid + '.' + port)
    obj_get = ObjectType(obj_id)

    auth = hlapi3.UsmUserData(
        userName=username,
        authKey=authKey,
        authProtocol=authProtocol,
        privKey=privKey,
        privProtocol=privProtocol
    )

    engine = hlapi3.SnmpEngine()

    iterator = await hlapi3.getCmd(
        engine,
        auth,
        connectto,
        hlapi3.ContextData(),
        obj_get
    )

    #errorIndication, errorStatus, errorIndex, varBinds = next(iterator)
    errorIndication, errorStatus, errorIndex, varBinds = iterator

    try:
        v0 = varBinds[0]
        i = v0[1]
        state={1:'on',2:'off'}[i]
    except Exception as e:
        print(e)
        state = None

    ###notify_dcws(port,state)

    return {
        'errorIndication': errorIndication,
        'errorStatus': errorStatus,
        'errorIndex': errorIndex,
        'varBinds': varBinds,
        'state': state,
    }


def check_iterator(iterator):
    errorIndication, errorStatus, errorIndex, varBinds = next(iterator)
    if errorIndication:
        print(errorIndication)
    if errorStatus:
        print(errorStatus)
    if errorIndex:
        print(errorIndex)
    if varBinds:
        print(varBinds[0].prettyPrint())


def get_args():

    parser = argparse.ArgumentParser(
            description="PoE set and get")

    parser.add_argument('port',
            help='Which physical port on the switch.',
            )

    parser.add_argument('state',
            help='1=on, 2=off',
            nargs='?',
            )

    parser.add_argument('--site-path', '-p',
            default = "/srv/www/pib",
            help="DJANGO_SETTINGS_MODULE")

    parser.add_argument('--django-settings', '-s',
            default = "pib.settings",
            help="DJANGO_SETTINGS_MODULE")

    parser.add_argument('-v', '--verbose', action="store_true")

    args = parser.parse_args()

    return args


def test_mkparams():
    params = mk_params()
    params['port'] = '2'
    pprint(params)
    o = asyncio.get_event_loop().run_until_complete(snmp_status( **params ))
    # o = snmp_set_state( state=1, **params )
    pprint(o)

def test():
    test_mkparams()

def init_dcwc(site_path, django_settings_module):
    sys.path.insert(0, site_path)
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", django_settings_module)

def main():
    args = get_args()

    init_dcwc(args.site_path, args.django_settings)

    params = mk_params()
    params['port'] = args.port

    o = asyncio.get_event_loop().run_until_complete(snmp_status( **params ))
    if args.verbose: pprint(o)

    i = transform_ret(o)
    state={1:'on',2:'off'}[i]
    print(f"{args.port=} {state=}")

    if args.state is not None:
        o = snmp_set_state( state=args.state, **params )
        if args.verbose: pprint(o)
        i = transform_ret(o)
        state={1:'on',2:'off'}[i]
        print(f"{args.port=} {state=}")


if __name__=='__main__':
    main()
