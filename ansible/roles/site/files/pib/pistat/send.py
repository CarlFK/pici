# pistat/send.py
# sends a message to the pistat websocket thing

import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "pib.settings")

import sys
sys.path.insert(0, '.' )

import django
django.setup()

from channels.layers import get_channel_layer

channel_layer = get_channel_layer()
print( type(channel_layer) )

from asgiref.sync import async_to_sync
async_to_sync(channel_layer.group_send("pi2", {"type": "chat.system_message", "text": "hello"} ) )


