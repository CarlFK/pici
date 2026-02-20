# pici pistat/views.py

import json
import subprocess
from pprint import pprint


from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

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

    group = f"pistat_{pi_name}"
    message_type = "stat.message"
    message = humanize(status)
    message_text = f"piview: {message}"
    d = {
            "type": message_type,
            "status": status,
            "message": message_text,
            }

    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, d )

    d['group'] = group

    response = HttpResponse(content_type="application/json")
    json.dump(d, response, indent=2)

    return response

@csrf_exempt
def ping(request, pi_name):

    # pi_name should be "pi{pi_no}"
    pi_oct = 100 + int(pi_name[2:])
    pi_ip = f"10.21.0.{pi_oct}"

    cmd = ["ping",
            "-c", "3",
            "-w", "5",
            pi_ip]

    p = subprocess.Popen(cmd,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()

    for line in stdout.decode().split('\n'):
        if line:
            status(request, pi_name, line)

    d = {"stdout": str(stdout), "stderr": str(stderr) }

    response = HttpResponse(content_type="application/json")
    json.dump(d, response, indent=2)

    return response
