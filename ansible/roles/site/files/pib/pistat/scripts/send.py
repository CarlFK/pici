# pistat/send.py
# sends a message to the pistat websocket thing

import argparse

import os

import sys

from channels.layers import get_channel_layer

from asgiref.sync import async_to_sync

def init(args):
    sys.path.insert(0, args.site_path)
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", args.django_settings)

def send_message(args):

    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)( args.group, {"type": args.type, "message": args.message} )

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
    init(args)
    send_message(args)
    # ret = test_args(args)


if __name__=='__main__':
    main()
