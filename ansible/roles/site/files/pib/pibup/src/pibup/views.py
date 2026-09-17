# pibup - pib upload form

import os

from django.http import HttpResponseRedirect, HttpResponseBadRequest
from django.shortcuts import render

from django.views.decorators.csrf import csrf_protect, csrf_exempt

import paramiko

from .forms import UploadFileForm

ALLOWED_EXTENSIONS = {".img", ".zip", ".gz", ".xz"}
MAX_UPLOAD_SIZE = 4 * 1024 * 1024 * 1024  # 4 GiB

# @csrf_exempt
def pibup(request):

    pino=request.GET['pino']
    print(f"{pino=}")

    if not pino.isdigit():
        return HttpResponseBadRequest("Invalid pino")
    safe_pino = int(pino)

    if request.method == "POST":
        form = UploadFileForm(request.POST, request.FILES)
        if form.is_valid():
            uploaded = request.FILES["file"]
            ext = os.path.splitext(uploaded.name)[1].lower()
            if ext not in ALLOWED_EXTENSIONS or uploaded.size > MAX_UPLOAD_SIZE:
                return HttpResponseBadRequest("Invalid file type or size")
            handle_uploaded_file(uploaded, pino)
            return HttpResponseRedirect(f"success?pino={safe_pino}")
    else:
        form = UploadFileForm()
    return render(request, "upload.html",
            {
                "pino": pino,
                "form": form,
                })

def handle_uploaded_file(f, pino):

    o=100+int(pino)
    ip=f'10.21.0.{o}'

    # print(f"{o=}, {ip=}")

    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    # client.connect("ps1.fpgas.mithis.com", username='pi', port=10222)
    client.connect(ip, username='pi')
    sftp = client.open_sftp()

    file_name=os.path.basename(f.name)

    with sftp.open(f"Uploads/{file_name}", "wb+") as destination:
        for chunk in f.chunks():
            destination.write(chunk)

def success(request):
    pino=request.GET['pino']
    return render(request, "success.html",
            {
                "pino": pino,
                })
