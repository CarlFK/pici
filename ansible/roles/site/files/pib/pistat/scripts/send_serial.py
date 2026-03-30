
import argparse
import json
import serial
import sys
import time

import send

class Serial:

    def __init__(self, serial_port, baudrate=19200):
        self.serial = serial.Serial()
        self.serial.port = serial_port
        self.serial.baudrate = 9600
        self.serial.timeout = 0.1
        self.serial.open()

    def read(self):
        rx = self.serial.readline()
        return rx

    def send(self, line):
        byts = line.encode()
        self.serial.write(byts)


def inspect(line, ser, grpname):

    if "denied" in line:
        send.send_message(
            group=grpname,
            message_type="stat.message",
            message_text="stopping status, who knows what the pi is doing?",
            )
        sys.exit()

    elif "FAILED" in line:
        send.send_message(
            group=grpname,
            message_type="stat.message",
            message_text="stopping status, who knows what the pi is doing?",
            )
        sys.exit()

    if line.endswith("login:"):
        print( "pi!" )
        # ser.send("pi\n")

    elif line.endswith("Password:"):
        print( "password!" )
        # ser.send("raspberry\n")
        # return True

    return False


def main():

    args = get_args()

    ser = Serial(args.device, args.baudrate)

    send.init(
            site_path="/srv/www/pib",
            django_settings_module="pib.settings",
            )

    login_cnt = 0

    if args.debug:
        for i in range(256):

            line = f"{i=} {chr(i)=}"

            send.send_message(
                group=args.grpname,
                message_type="stat.message",
                message_text=line,
                )

    while True:
        line = ser.read()
        if line is not None and line:

            line = line.decode(errors='ignore').strip()
            # line = line.decode().strip()
            print(line)
            # line = ''.join([char for char in line if char.isalnum() or char in r" []"])
            send.send_message(
                group=args.grpname,
                message_type="stat.message",
                message_text=line,
                )

            if login_cnt == 0:
                ret = inspect(line, ser, args.grpname)
                if ret:
                    login_cnt +=1



def get_args():

    parser = argparse.ArgumentParser(
            description="Get data from serial port, send to web socket.",
            formatter_class=argparse.ArgumentDefaultsHelpFormatter
            )

    parser.add_argument('--device', '-d',
            default="/dev/ttyUSB0",
            help="tty device of pico.")

    parser.add_argument('--baudrate', '-b',
            default = 115200,
            help="baudrate")

    parser.add_argument('--grpname', '-g',
            default="pistat_pi21",
            help="Group Name of Web Socket destination.")

    parser.add_argument('--debug',
            default=False,
            action='store_true',
            help="If there's something strange.")

    args = parser.parse_args()

    return args




if __name__=='__main__':
    main()
