from subprocess import Popen, PIPE, TimeoutExpired


def ping(ip):
    cmd = ["ping", "-c", "3", "-w", "5", ip]
    proc = Popen(cmd, stdin=PIPE, stdout=PIPE,stderr=PIPE)
    while proc.poll() is None:
        if line := proc.stdout.readline():
            line = line.decode().strip()
            print(line)

def main():
    ping("127.0.0.1")


if __name__=='__main__':
    main()
