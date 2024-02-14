# pistat/routing.py
from django.urls import re_path

from . import consumers

websocket_urlpatterns = [
    re_path(r"ws/pistat/(?P<pi_name>\w+)/$", consumers.PiStatConsumer.as_asgi()),
]
