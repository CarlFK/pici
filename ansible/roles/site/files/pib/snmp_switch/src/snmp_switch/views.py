from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

import json
import time
from pprint import pprint

from pysnmp import hlapi

from snmp_switch.utils import mk_params, snmp_set_state, snmp_status, snmp_toggle

def all_to_str(o):
    return o.__str__()

@csrf_exempt
def toggle(request):
    # turn the port off and on again

    params = mk_params()
    params['port'] = request.POST['port']

    ret = {}

    d = snmp_set_state( state='2', **params )
    ret['old'] = d['state']

    time.sleep(1)

    d = snmp_set_state( state='1', **params )
    ret['new'] = d['state']

    response = HttpResponse(content_type="application/json")
    json.dump(ret, response, indent=2, default=all_to_str)

    return response


@csrf_exempt
def toggle_all(request):

    params = mk_params()
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

    params = mk_params()
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

    params = mk_params()
    params['port'] = request.POST['port']
    d=snmp_status( **params )

    # d = {'snmp_status': d, 'raw': d.__str__() }
    d = {'state':d['state']}
    response = HttpResponse(content_type="application/json")
    json.dump(d, response, indent=2, default=all_to_str)

    return response
