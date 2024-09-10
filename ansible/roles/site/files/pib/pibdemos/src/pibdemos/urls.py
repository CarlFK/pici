# pib/snmp_switch/urls.py

from django.urls import path

from pibdemos.views import blink, micro_python, linux

urlpatterns = [
    path('blink', blink),
    path('up', micro_python),
    path('linux', linux),
]
