# pistat/send.py
# sends a message to the websocket thing

import argparse
import os
import sys

from channels.layers import get_channel_layer

from asgiref.sync import async_to_sync

def init(site_path, django_settings_module):
    sys.path.insert(0, site_path)
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", django_settings_module)

def send_message(group, message_type, message_text):
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( group, {"type": message_type, "message": message_text} )

def get_args():

    parser = argparse.ArgumentParser(
            description="Send a status message to the chate server.",
            formatter_class=argparse.ArgumentDefaultsHelpFormatter
            )

    parser.add_argument('--group', '-g',
            default="pistat_pi2",
            help="The group to send a message to.")

    parser.add_argument('--type', '-t',
            default="stat.message",
            help="The type of message.")

    parser.add_argument('--message', '-m',
            default = parser.prog,
            help="Default.")

    parser.add_argument('--site-path', '-p',
            default = "/srv/www/pib",
            help="DJANGO_SETTINGS_MODULE")

    parser.add_argument('--django-settings', '-s',
            default = "pib.settings",
            help="DJANGO_SETTINGS_MODULE")

    parser.add_argument('--debug', '-d', default=False,
            action='store_true',
            help='Drop to prompt after toot.')

    args = parser.parse_args()

    return args


def main():
    args = get_args()
    init(args.site_path, args.django_settings)
    send_message(args.group, args.type, args.message)
    # ret = test_args(args)


if __name__=='__main__':
    main()
