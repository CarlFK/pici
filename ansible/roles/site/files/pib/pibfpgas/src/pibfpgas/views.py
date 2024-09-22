# pibup - pib upload form

from base64 import b64encode

from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.shortcuts import get_object_or_404

from django.conf import settings

from .models import Pi

from pibup.forms import UploadFileForm


def home(request):

    pis = Pi.objects.all()

    return render(request, "index.html",
            {
                'pis': pis,
                "domain_name": settings.DOMAIN_NAME,
                })


def one(request, pino):

    pi = get_object_or_404(Pi, port=pino)

    o=100+int(pino)
    ip=f'10.21.0.{o}'

    form = UploadFileForm()

    return render(request, "fpga.html",
            {
                "pi": pi,
                "pino": pino,
                "o": o,
                "ip": ip,
                "pw": settings.PI_PW,
                "domain_name": settings.DOMAIN_NAME,
                "form": form,
                })
