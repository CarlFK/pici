from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

import json
from pprint import pprint

from channels.layers import get_channel_layer

from asgiref.sync import async_to_sync

def humanize(m):
    # given a key, add a bunch of text to make humans happy

    # d = {"type": message_type, "message": message_text}

    xtra=None

    if 'kernel' in m:
        xtra = "Linux kernel booting, (this can take up to 2 minutes - see https://github.com/CarlFK/pici/issues/33)"
    else:
        xtra = {
            'cam': 'cam sending video feed to server (60 second latency.)',
            'ssh': 'ssh server started.',
            'ArtyHere': 'Arty board detected.',
            'NoArty': 'Arty board not detected. probably because https://github.com/CarlFK/pici/issues/39',
            'ArtyHere': 'Arty board detected.',
            'ArtyWire': 'Arty pmod wire test passed.',
            'ArtyNoWire': 'Arty pmod wire test failed.',
            }.get(m)

    if xtra is not None:
        m = f"{m} {xtra}"

    return m


@csrf_exempt
def status(request, pi_name, status):

    status = humanize(status)

    group = f"pistat_{pi_name}"
    message_type = "stat.message"
    message_text = f"piview: {status}"
    d = {"type": message_type, "message": message_text}


    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, d )

    d['group'] = group

    response = HttpResponse(content_type="application/json")
    json.dump(d, response, indent=2)

    return response
