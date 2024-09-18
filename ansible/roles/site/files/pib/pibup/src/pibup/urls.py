# pib/pibup/urls.py

from django.urls import path

from pibup.views import pibup, success

urlpatterns = [
    path('upload', pibup),
    path('success', success),
]
