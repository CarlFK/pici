# pistat/consumers.py
import json

from pprint import pprint

from channels.generic.websocket import WebsocketConsumer
from asgiref.sync import async_to_sync


class PiStatConsumer(WebsocketConsumer):

    def connect(self):
        pprint(self.channel_name)
        self.channel_layer.group_add("pistat", self.channel_name)

    def disconnect(self, close_code):
        self.channel_layer.group_discard("pistat", self.channel_name)

    def receive(self, text_data):

        pprint(text_data)

        self.channel_layer.group_send(
            "pistat",
            {
                "type": "message",
                "text": text_data,
            },
        )

    def message(self, event):
        self.send(text_data=event["text"])

    def notify(self, event):
        print("notify:")
        print(event)
