from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

import json
from pprint import pprint

from channels.layers import get_channel_layer

from asgiref.sync import async_to_sync

@csrf_exempt
def status(request, pi_name, status):

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
