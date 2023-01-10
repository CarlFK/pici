# pib/snmp_switch/urls.py

from django.urls import path

from snmp_switch.views import status, toggle, toggle_all

urlpatterns = [
    path('status', status),
    path('toggle', toggle),
    path('toggle_all', toggle_all),
    path('off_all', off_all),
]
