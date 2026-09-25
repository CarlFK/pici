from subprocess import Popen, PIPE, TimeoutExpired

from pprint import pprint
import json

import time

def ping(ip):
    cmd = ["ping", "-c", "3", "-w", "5", ip]

    proc = Popen(cmd, stdin=PIPE, stdout=PIPE,stderr=PIPE)
    while (line := proc.stdout.readline()) or (proc.poll() is not None):
            line = line.decode().strip()
            print(line)
            time.sleep(1)

def main():
    ping("127.0.0.1")


if __name__=='__main__':
    main()
