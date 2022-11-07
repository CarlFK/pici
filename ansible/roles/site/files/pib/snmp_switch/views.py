from django.conf import settings
from django.shortcuts import render
from django.http import HttpResponse

import json
from pprint import pprint

from snmp_switch.utils import snmp_status, snmp_toggle

# TODO: move settings into app settings/config.

def toggle(request, extra_context={}):

    port = request.GET['port']

    context = {}
    context.update(extra_context)

    context.update(snmp_toggle(
        host=settings.SNMP_SWITCH_HOST,
        username=settings.SNMP_SWITCH_USERNAME,
        authkey=settings.SNMP_SWITCH_AUTHKEY,
        privkey=settings.SNMP_SWITCH_PRIVKEY,
        oid=settings.SNMP_SWITCH_OID,
        port=port))

    pprint(context)

    response = HttpResponse(content_type="application/json")
    d={'port': port, 'value': 1}
    json.dump(d, response, indent=2)

    return response


def status(request, template_name='snmp_status.html', extra_context={}):

    port = request.GET['port']

    context = {}
    context.update(extra_context)

    context.update(snmp_status(
        host=settings.SNMP_SWITCH_HOST,
        username=settings.SNMP_SWITCH_USERNAME,
        authkey=settings.SNMP_SWITCH_AUTHKEY,
        privkey=settings.SNMP_SWITCH_PRIVKEY,
        oid=settings.SNMP_SWITCH_OID,
        port=port))

    pprint(context)

    response = HttpResponse(content_type="application/json")
    d={'port':port, 'value':1}
    # json.dump(context, response, indent=2)
    json.dump(d, response, indent=2)

    return response
    # return render(request, template_name=template_name, context=context)
