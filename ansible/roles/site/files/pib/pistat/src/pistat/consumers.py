# chat/consumers.py
import json

from pprint import pprint

from channels.generic.websocket import AsyncWebsocketConsumer


class PiStatConsumer(AsyncWebsocketConsumer):

    async def connect(self):
        self.pi_name = self.scope["url_route"]["kwargs"]["pi_name"]
        self.group_name = f"pistat_{self.pi_name}"

        # Join group
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        # Leave group
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    # Receive message from WebSocket
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        pprint(text_data_json)
        message = text_data_json["stat.message"]

        # Send message to group
        await self.channel_layer.group_send(
            self.group_name, {"type": "stat.message", "message": message}
        )

    # Receive message from group
    async def stat_message(self, event):
        pprint(event)
        # {'message': 'x', 'type': 'stat.message'}
        message = event["message"]

        # Send message to WebSocket
        await self.send(text_data=json.dumps({"message": message}))
