from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

import json
import time
from pprint import pprint

from pysnmp import hlapi

from snmp_switch.utils import mk_params, snmp_get_state, snmp_set_state

# so we can send the browser a message when the power goes off and on:
# tangle up this code with the django-connect web socket code :(
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

def notify_dcws(port,state):

    # send message to browser via web socket

    pi_name=f"pi{port}"
    group = f"pistat_{pi_name}"
    message_type="stat.message"
    message_text=f"snmp: power {state}"
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, {"type": message_type, "message": message_text} )


@csrf_exempt
def status(request):
    # get_state (it's a getter yo.)

    params = mk_params()

    o = json.loads(request.body)
    port = o['port']
    params['port'] = port

    d=snmp_get_state( **params )

    d = {'state':d['state']}
    notify_dcws(port,d['state'])

    response = HttpResponse(content_type="application/json")
    json.dump(d, response)

    return response

@csrf_exempt
def toggle(request):
    # turn the port off and on again

    o = json.loads(request.body)
    port = o['port']

    params = mk_params()
    params['port'] = port

    ret = {port:[]}

    d = snmp_set_state( state='2', **params )
    notify_dcws(port,d['state'])
    ret[port].append(d['state'])

    time.sleep(.5)

    d = snmp_set_state( state='1', **params )
    notify_dcws(port,d['state'])
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
        notify_dcws(port,d['state'])
        ret[port].append(d['state'])

    time.sleep(1)

    # all on:
    for port in range(1,48):
        params['port'] = str(port)
        d = snmp_set_state( state='1', **params )
        notify_dcws(port,d['state'])
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
        notify_dcws(port,d['state'])
        ret[port].append(d['state'])

    response = HttpResponse(content_type="application/json")
    json.dump(ret, response, indent=2)

    return response


