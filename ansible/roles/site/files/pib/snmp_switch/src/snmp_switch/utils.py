import argparse
import asyncio
import sys
import os

from pprint import pprint
from time import sleep

import pysnmp

from pysnmp.hlapi import v3arch
from pysnmp.proto import rfc1902
from pysnmp.smi.rfc1902 import ObjectIdentity, ObjectType


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

    map those cli strings to pysnmp.hlapi constants:
    """

    k = os.environ.get('SNMP_SWITCH_AUTH_PROTOCOL')
    params['authProtocol'] = {
        'NoAuth': v3arch.asyncio.USM_AUTH_NONE,
        'MD5':    v3arch.asyncio.USM_AUTH_HMAC96_MD5,
        'SHA':    v3arch.asyncio.USM_AUTH_HMAC96_MD5,
        'SHA224': v3arch.asyncio.USM_AUTH_HMAC128_SHA224,
        'SHA256': v3arch.asyncio.USM_AUTH_HMAC192_SHA256,
        'SHA384': v3arch.asyncio.USM_AUTH_HMAC256_SHA384,
        'SHA512': v3arch.asyncio.USM_AUTH_HMAC384_SHA512,
        }[k]

    """
    same for
   -x PRIV-PROTOCOL      privacy protocol ID (3DES|AES|AES128|AES192|AES192BLMT|AES256|AES256BLMT|DES)
    """

    k = os.environ.get('SNMP_SWITCH_PRIV_PROTOCOL')
    params['privProtocol'] = {
        'NoPriv':     v3arch.asyncio.USM_AUTH_HMAC384_SHA512,
        '3DES':       v3arch.asyncio.USM_PRIV_CBC168_3DES,
        'AES':        None,
        'AES128':     v3arch.asyncio.USM_PRIV_CFB128_AES,
        'AES192':     v3arch.asyncio.USM_PRIV_CFB192_AES,
        'AES192BLMT': None,
        'AES256':     v3arch.asyncio.USM_PRIV_CFB256_AES,
        'AES256BLMT': None,
        'DES':        v3arch.asyncio.USM_PRIV_CBC56_DES,
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

async def snmp_get_state(host, username, authKey, privKey, oid, port,
        authProtocol, privProtocol):

    connectto = await v3arch.asyncio.UdpTransportTarget.create((host, 161))
    obj_id = ObjectIdentity(oid + '.' + port)
    obj_get = ObjectType(obj_id)

    auth = v3arch.asyncio.UsmUserData(
        userName=username,
        authKey=authKey,
        authProtocol=authProtocol,
        privKey=privKey,
        privProtocol=privProtocol
    )

    engine = v3arch.asyncio.SnmpEngine()

    iterator = await v3arch.asyncio.get_cmd(
        engine,
        auth,
        connectto,
        v3arch.asyncio.ContextData(),
        obj_get
    )

    errorIndication, errorStatus, errorIndex, varBinds = iterator

    try:
        v0 = varBinds[0]
        i = v0[1]
        state={1:'on',2:'off'}[i]
    except Exception as e:
        print(e)
        state = None

    return {
        'errorIndication': errorIndication,
        'errorStatus': errorStatus,
        'errorIndex': errorIndex,
        'varBinds': varBinds,
        'state': state,
    }



async def snmp_set_state(host, username, authKey, privKey, oid, port, state,
        authProtocol, privProtocol):

    """
    state:
        1=on
        2=off
    """

    connectto = await v3arch.asyncio.UdpTransportTarget.create((host, 161))
    obj_id = ObjectIdentity(oid + '.' + port)

    obj_state = ObjectType(obj_id, rfc1902.Integer(state))

    auth = v3arch.UsmUserData(
        userName=username,
        authKey=authKey,
        authProtocol=authProtocol,
        privKey=privKey,
        privProtocol=privProtocol,
    )

    engine = v3arch.SnmpEngine()

    iterator = await v3arch.set_cmd(
        engine,
        auth,
        connectto,
        v3arch.ContextData(),
        obj_state
    )
    errorIndication, errorStatus, errorIndex, varBinds = iterator

    try:
        v0 = varBinds[0]
        i = v0[1]
        state={1:'on',2:'off'}[i]
    except Exception as e:
        print(e)
        state = None

    ret = {
            'errorIndication': errorIndication,
            'errorStatus': errorStatus,
            'errorIndex': errorIndex,
            'varBinds': varBinds,
            'state': state,
    }

    return ret



def get_args():

    parser = argparse.ArgumentParser(
            description="PoE get and set")

    parser.add_argument('port',
            help='Which physical port on the switch.',
            nargs='?',
            )

    parser.add_argument('state',
            help='1=on, 2=off',
            nargs='?',
            )

    parser.add_argument('-t', '--test', help="run test(s)", action="store_true")
    parser.add_argument('-v', '--verbose', action="store_true")

    args = parser.parse_args()

    return args


def test_mkparams(args):
    params = mk_params()
    params['port'] = args.port
    pprint(params)
    # o = asyncio.get_event_loop().run_until_complete(snmp_get_state( **params ))
    # o = asyncio.run( snmp_get_state(**params) )
    # pprint(o)

def test(args):
    test_mkparams(args)

def main2(args):

    params = mk_params()
    params['port'] = args.port

    o=asyncio.run( snmp_get_state(**params) )
    if args.verbose: pprint(o)

    i = transform_ret(o)
    state={1:'on',2:'off'}[i]
    print(f"{args.port=} {state=}")

    if args.state is not None:
        o=asyncio.run( snmp_set_state(**params, state=args.state) )
        if args.verbose: pprint(o)
        i = transform_ret(o)
        state={1:'on',2:'off'}[i]
        print(f"{args.port=} {state=}")


def main():
    args = get_args()

    if args.test:
        test(args)
    else:
        main2(args)

if __name__=='__main__':
    main()
