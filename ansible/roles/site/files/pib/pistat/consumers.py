# pistat/consumers.py
import json

from pprint import pprint

from channels.generic.websocket import WebsocketConsumer


class PiStatConsumer(WebsocketConsumer):
    def connect(self):
        self.accept()

    def disconnect(self, close_code):
        pass

    def receive(self, text_data):
        text_data_json = json.loads(text_data)

        # pprint(text_data_json)
        # {'message': 'abc'}

        pprint(self.scope)
        # ... 'url_route': {'args': (), 'kwargs': {'pi_name': 'pi2'}},
        print(f"{self.scope['url_route']['kwargs']['pi_name']=}")
        # self.scope['url_route']['kwargs']['pi_name']='pi2'

        pi_name = self.scope['url_route']['kwargs']['pi_name']

        message = text_data_json["message"]

        self.send(text_data=json.dumps({"message": message}))
