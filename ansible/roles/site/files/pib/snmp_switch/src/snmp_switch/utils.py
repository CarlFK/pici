import argparse
import sys
import os

from pprint import pprint
from time import sleep

from pysnmp import hlapi
from pysnmp.proto import rfc1902

# so we can send the browser a message when the power goes off and on:
# tangle up this code with the django-connect web socket code :(
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync


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

    # put all the thigns here and return it
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
        'NoAuth': hlapi.usmNoAuthProtocol,
        'MD5': hlapi.usmHMACMD5AuthProtocol,
        'SHA': hlapi.usmHMACSHAAuthProtocol,
        'SHA224': hlapi.usmHMAC128SHA224AuthProtocol,
        'SHA256': hlapi.usmHMAC192SHA256AuthProtocol,
        'SHA384': hlapi.usmHMAC256SHA384AuthProtocol,
        'SHA512': hlapi.usmHMAC384SHA512AuthProtocol,
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
        'NoPriv': hlapi.usmNoPrivProtocol,
        '3DES': hlapi.usm3DESEDEPrivProtocol,
        'AES': None,
        'AES128': hlapi.usmAesCfb128Protocol,
        'AES192': hlapi.usmAesCfb192Protocol,
        'AES192BLMT': None,
        'AES256': hlapi.usmAesCfb256Protocol,
        'AES256BLMT': None,
        'DES': hlapi.usmDESPrivProtocol,
        }[k]

    # port is the rj45 port on the 24 or 48 or howmanyever port switch.
    # not tcp/udp port.  (which seems to be udp 161)
    # it is set here just to document it.
    params['port'] = None

    return params

def transform_ret(o):
    # if o['errorIndication'] is None:
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
    obj_id = hlapi.ObjectIdentity(oid + '.' + port)

    obj_state = hlapi.ObjectType(obj_id, rfc1902.Integer(state))

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

    notify_dcws(port,state)

    ret = {
            'errorIndication': errorIndication,
            'errorStatus': errorStatus,
            'errorIndex': errorIndex,
            'varBinds': varBinds,
            'state': state,
    }

    return ret


def snmp_toggle(host, username, authKey, privKey, oid, port,
        authProtocol, privProtocol):

    connectto = hlapi.UdpTransportTarget((host, 161))
    obj_id = hlapi.ObjectIdentity(oid + '.' + port)
    obj_off = hlapi.ObjectType(obj_id, rfc1902.Integer(2))
    obj_on = hlapi.ObjectType(obj_id, rfc1902.Integer(1))

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
        obj_off
    )
    errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

    pi_name=f"pi{port}"
    group = f"pistat_{pi_name}"
    message_type="stat.message"

    message_text="snmp: power off"
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, {"type": message_type, "message": message_text} )

    sleep(2)

    iterator = hlapi.setCmd(
        engine,
        auth,
        connectto,
        hlapi.ContextData(),
        obj_on
    )
    errorIndication2, errorStatus2, errorIndex2, varBinds2 = next(iterator)

    message_text="snmp: power on"
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, {"type": message_type, "message": message_text} )

    return {
            'errorIndication': errorIndication,
            'errorStatus': errorStatus,
            'errorIndex': errorIndex,
            'varBinds': varBinds,
            'errorIndication2': errorIndication2,
            'errorStatus2': errorStatus2,
            'errorIndex2': errorIndex2,
            'varBinds2': varBinds2
    }


def snmp_status(host, username, authKey, privKey, oid, port,
        authProtocol, privProtocol):

    connectto = hlapi.UdpTransportTarget((host, 161))
    obj_id = hlapi.ObjectIdentity(oid + '.' + port)
    obj_get = hlapi.ObjectType(obj_id)

    auth = hlapi.UsmUserData(
        userName=username,
        authKey=authKey,
        authProtocol=authProtocol, #usmHMACSHAAuthProtocol,
        privKey=privKey,
        privProtocol=privProtocol #usmAesCfb256Protocol
    )

    engine = hlapi.SnmpEngine()

    iterator = hlapi.getCmd(
        engine,
        auth,
        connectto,
        hlapi.ContextData(),
        obj_get
    )

    errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

    return {
        'errorIndication': errorIndication,
        'errorStatus': errorStatus,
        'errorIndex': errorIndex,
        'varBinds': varBinds
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

"""
check_iterator(get_cmd(obj_get))
#print(obj_id.getOid(), ' - ', obj_id.getLabel(), ' - ', obj_id.getMibSymbol())

# Turn the port off.
check_iterator(set_cmd(obj_off))
sleep(2)
check_iterator(get_cmd(obj_get))
sleep(2)

# Turn the port on.
check_iterator(set_cmd(obj_on))
sleep(2)
check_iterator(get_cmd(obj_get))
"""

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

    args = parser.parse_args()

    return args


def test_mkparams():
    params = mk_params()
    params['port'] = '2'
    pprint(params)
    o = snmp_status( **params )
    # o = snmp_set_state( state=1, **params )
    # o = snmp_toggle( **params )
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

    o = snmp_status( **params )
    i = transform_ret(o)
    state={1:'on',2:'off'}[i]
    print(f"{args.port=} {state=}")

    if args.state is not None:
        o = snmp_set_state( state=args.state, **params )
        i = transform_ret(o)
        state={1:'on',2:'off'}[i]
        print(f"{args.port=} {state=}")


if __name__=='__main__':
    main()
