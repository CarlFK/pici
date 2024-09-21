# pib/pibup/urls.py

from django.urls import path

from pibfpgas.views import home, one

urlpatterns = [
    path('', home),
    path('pi<int:pino>.html', one),
]
