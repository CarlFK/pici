# pib/pibup/urls.py

from django.urls import path

from pibfpgas.views import home, arty, tt

urlpatterns = [
    path('', home),
    path('pi<int:pino>.html', arty),
    path('tt<int:ttno>.html', tt),
]

