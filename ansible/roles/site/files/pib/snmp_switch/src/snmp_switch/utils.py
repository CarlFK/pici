import os

from pprint import pprint
from time import sleep

from pysnmp import hlapi
from pysnmp.proto import rfc1902


def mk_params():
    # construct params: a dictionary of parameters

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
            print(f"{ev_name=} {ev_val=}")
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

    ret = {
            'errorIndication': errorIndication,
            'errorStatus': errorStatus,
            'errorIndex': errorIndex,
            'varBinds': varBinds,
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

    sleep(2)
    iterator = hlapi.setCmd(
        engine,
        auth,
        connectto,
        hlapi.ContextData(),
        obj_on
    )
    errorIndication2, errorStatus2, errorIndex2, varBinds2 = next(iterator)

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

if __name__=='__main__':
    test()
