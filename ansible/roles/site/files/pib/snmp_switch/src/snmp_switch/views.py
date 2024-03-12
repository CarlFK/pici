from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

import json
import time
from pprint import pprint

from pysnmp import hlapi

from snmp_switch.utils import mk_params, snmp_set_state, snmp_status, snmp_toggle

@csrf_exempt
def toggle(request):
    # turn the port off and on again

    o = json.loads(request.body)
    port = o['port']

    params = mk_params()
    params['port'] = port

    ret = {port:[]}

    d = snmp_set_state( state='2', **params )
    ret[port].append(d['state'])

    time.sleep(1)

    d = snmp_set_state( state='1', **params )
    ret[port].append(d['state'])

    response = HttpResponse(content_type="application/json")
    json.dump(ret, response, indent=2)

    return response


@csrf_exempt
def toggle_all(request):

    params = mk_params()

    ret = { port:[] for port in range(48) }

    # all off:
    for port in range(1,48):
        params['port'] = str(port)
        d = snmp_set_state( state='2', **params )
        ret[port].append(d['state'])

    time.sleep(1)

    # all on:
    for port in range(1,48):
        params['port'] = str(port)
        d = snmp_set_state( state='1', **params )
        ret['was'][port] = d['state']

    response = HttpResponse(content_type="application/json")
    json.dump(ret, response, indent=2)

    return response

@csrf_exempt
def off_all(request):

    # 2=off
    # params['state']=2

    params = mk_params()
    ret = { port:[] for port in range(48) }

    # all off:
    for port in range(1,48):
        params['port'] = str(port)
        d = snmp_set_state( state='2', **params )
        ret[port].append(d['state'])

    response = HttpResponse(content_type="application/json")
    json.dump(ret, response, indent=2)

    return response


@csrf_exempt
def status(request):

    params = mk_params()

    o = json.loads(request.body)
    port = o['port']
    params['port'] = port

    d=snmp_status( **params )

    d = {'state':d['state']}
    response = HttpResponse(content_type="application/json")
    json.dump(d, response)

    return response
