import json

from django.shortcuts import render
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt

from pibdemos.utils import run_on_pi

@csrf_exempt
def blink(request):
    cmd = '/usr/bin/openFPGALoader -b arty /home/pi/tests/counter_test/top.bit'.split()

    o = json.loads(request.body)
    port = o['port']

    stdin, stdout, stderr = run_on_pi(port,cmd)
    ret={}
    ret['stdout']=list(stdout)
    ret['stderr']=list(stderr)

    response = HttpResponse(content_type="application/json")
    json.dump(ret, response, indent=2)

    return response

def micro_python(request):
    pass

def linux(request):
    pass
