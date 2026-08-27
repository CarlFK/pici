# pibup - pib upload form

from itertools import groupby

from django.shortcuts import render
from django.shortcuts import get_object_or_404

from django.conf import settings

from .models import Pi, BOARD_TYPES

from pibup.forms import UploadFileForm

BOARD_TYPE_LABELS = dict(BOARD_TYPES)


def home(request):

    pis = Pi.objects.all().order_by('board_type', 'port')

    board_groups = []
    for board_type, group in groupby(pis, key=lambda p: p.board_type):
        board_groups.append({
            'type': board_type,
            'label': BOARD_TYPE_LABELS.get(board_type, board_type),
            'pis': list(group),
        })

    return render(request, "index.html",
            {
                'board_groups': board_groups,
                "domain_name": settings.DOMAIN_NAME,
                })


def one(request, pino, template=None):

    # pino: Pi Number (the port on the network switch the Pi is plugged into.)

    pi = get_object_or_404(Pi, port=pino)

    # Auto-select template based on board type if not explicitly provided
    if template is None:
        if pi.board_type in ('tt_asic', 'tt_fpga'):
            template = 'tt.html'
        else:
            template = 'fpga.html'

    o=100+int(pino)
    ip=f'10.21.0.{o}'

    form = UploadFileForm()

    return render(request, template,
            {
                "pi": pi,
                "pino": pino,
                "o": o,
                "ip": ip,
                "pw": settings.PI_PW,
                "domain_name": settings.DOMAIN_NAME,
                "form": form,
                })


def tt(request):
    return one(request, 21, 'tt.html')

