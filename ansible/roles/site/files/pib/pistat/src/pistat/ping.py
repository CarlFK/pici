from subprocess import Popen, PIPE, TimeoutExpired

import os


def ping(ip):

    cmd = ["ping",
            "-c", "3",
            "-w", "5",
            ip]

    proc = Popen(cmd,
        stdin=PIPE, stdout=PIPE,stderr=PIPE)

    os.set_blocking(proc.stdout.fileno(), False)

    while proc.poll() is None:
        line=proc.stdout.readline()
        line=line.decode().strip()
        if line:
            print(line)

    lines=proc.stdout.read()
    lines=lines.decode()
    for line in lines.split('\n'):
        line=line.strip()
        if line:
            print(line)


def main():
    ping("127.0.0.1")

if __name__=='__main__':
    main()
