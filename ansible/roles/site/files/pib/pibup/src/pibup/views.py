# pibup - pib upload form

from django.http import HttpResponseRedirect
from django.shortcuts import render

import paramiko

from .forms import UploadFileForm

def pibup(request):
    pino=request.GET['pino']
    print(f"{pino=}")
    if request.method == "POST":
        form = UploadFileForm(request.POST, request.FILES)
        if form.is_valid():
            run = form.cleaned_data['run']
            handle_uploaded_file(request.FILES["file"], pino, run)
            return HttpResponseRedirect(f"success?pino={pino}")
    else:
        form = UploadFileForm()
    return render(request, "upload.html",
            {
                "form": form,
                "pino": pino,
                })

def handle_uploaded_file(f, pino, run):

    o=100+int(pino)
    ip=f'10.21.0.{o}'

    print(f"{o=}, {ip=}, {run=}")

    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    # client.connect("ps1.fpgas.mithis.com", username='pi', port=10222)
    client.connect(ip, username='pi')
    sftp = client.open_sftp()

    file_name=f.name

    with sftp.open(f"Uploads/{file_name}", "wb+") as destination:
        for chunk in f.chunks():
            destination.write(chunk)

def success(request):
    pino=request.GET['pino']
    print(f"{pino=}")
    return render(request, "success.html",
            {
                "pino": pino,
                })
