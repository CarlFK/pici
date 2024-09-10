import json

from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

from pibdemos.utils import run_on_pi

def rop(request, cmd):
    # rop = Run On Pi
    # pull the port from the request, send port,cmd to pibdemos.utils.run_on_pi

    o = json.loads(request.body)
    port = int(o['port'])

    ret = run_on_pi(port,cmd)

    response = HttpResponse(content_type="application/json")
    json.dump(ret, response, indent=2)

    return response

@csrf_exempt
def blink(request):
    cmd = '/usr/bin/openFPGALoader -b arty /home/pi/tests/counter_test/top.bit'
    response=rop(request,cmd)
    return response

@csrf_exempt
def micro_python(request):
    pass

@csrf_exempt
def linux(request):

    cmd = 'cp -v /home/pi/tests/linux_litex_t1/tftp/* /srv/tftp'
    response=rop(request,cmd)

    cmd = '/usr/bin/openFPGALoader -b arty /home/pi/tests/linux_litex_t1/top.bit'
    response=rop(request,cmd)

    return response
