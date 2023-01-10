from pysnmp.hlapi import UsmUserData, usmHMACSHAAuthProtocol, \
                         usmAesCfb256Protocol, usmHMACMD5AuthProtocol, \
                         usmDESPrivProtocol, \
                         ObjectType, ObjectIdentity, getCmd, setCmd, \
                         UdpTransportTarget, SnmpEngine, ContextData

from pysnmp.proto import rfc1902

from time import sleep

def snmp_set_state(host, username, authkey, privkey, oid, port, state,
        authProtocol=usmHMACMD5AuthProtocol, privProtocol=usmDESPrivProtocol):

    """
    state:
    1=on
    2=off
    """

    connectto = UdpTransportTarget((host, 161))
    obj_id = ObjectIdentity(oid + '.' + port)

    obj_state = ObjectType(obj_id, rfc1902.Integer(state))

    auth = UsmUserData(
        userName=username,
        authKey=authkey,
        authProtocol=authProtocol, #usmHMACSHAAuthProtocol,
        privKey=privkey,
        privProtocol=privProtocol #usmAesCfb256Protocol
    )

    engine = SnmpEngine()

    iterator = setCmd(
        engine,
        auth,
        connectto,
        ContextData(),
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


def snmp_toggle(host, username, authkey, privkey, oid, port,
        authProtocol=usmHMACMD5AuthProtocol, privProtocol=usmDESPrivProtocol):

    connectto = UdpTransportTarget((host, 161))
    obj_id = ObjectIdentity(oid + '.' + port)
    obj_off = ObjectType(obj_id, rfc1902.Integer(2))
    obj_on = ObjectType(obj_id, rfc1902.Integer(1))

    auth = UsmUserData(
        userName=username,
        authKey=authkey,
        authProtocol=authProtocol, #usmHMACSHAAuthProtocol,
        privKey=privkey,
        privProtocol=privProtocol #usmAesCfb256Protocol
    )

    engine = SnmpEngine()

    iterator = setCmd(
        engine,
        auth,
        connectto,
        ContextData(),
        obj_off
    )
    errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

    sleep(2)
    iterator = setCmd(
        engine,
        auth,
        connectto,
        ContextData(),
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


def snmp_status(host, username, authkey, privkey, oid, port,
        authProtocol=usmHMACMD5AuthProtocol, privProtocol=usmDESPrivProtocol):
    connectto = UdpTransportTarget((host, 161))
    obj_id = ObjectIdentity(oid + '.' + port)
    obj_get = ObjectType(obj_id)

    auth = UsmUserData(
        userName=username,
        authKey=authkey,
        authProtocol=authProtocol, #usmHMACSHAAuthProtocol,
        privKey=privkey,
        privProtocol=privProtocol #usmAesCfb256Protocol
    )

    engine = SnmpEngine()

    iterator = getCmd(
        engine,
        auth,
        connectto,
        ContextData(),
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
