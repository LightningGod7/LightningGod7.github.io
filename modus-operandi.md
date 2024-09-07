# Why having an MO is important
Leading up to my own exam, I have read tons of "How I passed OSCP in 6 hours" medium writeups. Most of them give links to cheat sheets, notes and even good tips on how to strategise your exam approach. Most however, don't tell you about how you can create your own 'engagement style'.

The exam is a 24 hour long process and as humans, we are bound to get tired and make mistakes, even with cheat sheets and a ton of materials. I have always thought that it is important to automate as many menial tasks as possible. This includes things like replacing "$LHOST" and "$LPORT" in your cheatsheet, running off to revshells.com to plug in your address and ports to copy your rev shell command, running cert-util commands multiple times across multiple hosts just to transfer the same files on to your targets...

My MO involves techniques and habits to streamline all these processes. From my own experience in my exam, this saved me a ton of time and allowed me to utilize my brain juice on the more important things.

# [Aliases](materials/alias.txt)

```bash
alias update='sudo -- sh -c "apt update && apt upgrade"'
alias bo='cat /pt/reference/breakout'
alias me="ip -o -4 addr list tun0 | awk '{print \$4}' | cut -d/ -f1"
alias rrev='rlwrap nc -nvlp'
alias rev="head -n 3 /pt/reference/breakout ; nc -nvlp"
alias serv='python3 -m http.server'
alias sserv='impacket-smbserver kali . -smb2support'
```
I use aliases to shorten most commonly used commands during the exam. Aliases are placed in ~/.bashrc or ~/.zshrc. Once you have added your aliases, remember to run `source <your rc file>`
me - prints out the tun0 ip address
bo - prints linux shell breakout and upgrade commands
rev - quickly spawns a reverse listener and prints shell upgrade commands to copy and paste when you get your linux reverse shell connection
rrev - quickly spawns a reverse listener with rlwrap for windows reverse shells
serv - python http server in current directory (remember to specify your port at the back)
sserv - smb server in current directory

p.s. do remember to change the paths for files like 'breakout' if you do use my aliases.

# Services to run

## Apache Web-server
I have an apache server systemctl-enabled. The root directory is pointed to `/serve` on my kali and is hosted on port 8000. `/serve` contains a bunch of binaries, scripts I commonly transfer to my targets upon gaining access. E.g. linpeas, pspy64, powerup, powerview etc.

## Code-server
Code server is basically vs code running as a webserver. You can access this remotely, for example outside your vm on your actual host.
I keep a code-server running for me to quickly debug or edit scripts without having to nano in on my already flooded terminal. 

# Shortcut folders
Do symbolic links on your vm to quickly access most used files. Some examples of what I do are as such

`/pt -> /mnt/NAS/OSCP/essentials` - I store all of my OSCP materials on a NAS and mounted it onto my VM 
`/serve -> /var/www/html` - apache server root path

`/wls -> /usr/share/wordlist` - yes im lazy to type that all out everytime on hydra or hashcat

# Must have programs

## [Ligolo](https://github.com/nicocha30/ligolo-ng/)
Ligolo is a tool used for port-forwarding and tunneling. It is not taught in the PEN-200 material but it is way easier to use as compared to the tools they do teach you.
You will find all the below commands in my cheat sheet. (except the installation)

### Installing
```bash 
#Download Agent
#Linux
sudo wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.4.3/ligolo-ng_agent_0.4.3_Linux_64bit.tar.gz
tar -xvf 
#Windows
sudo wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.5.1/ligolo-ng_agent_0.5.1_windows_amd64.zip
unzip
#Download Proxy
sudo wget https://github.com/nicocha30/ligolo-ng/releases/download/v0.4.3/ligolo-n
tar -xvf
```

### Proxy
```bash
#create tun interface for ligolo
sudo ip tuntap add user kali mode tun ligolo
sudo ip link set ligolo up

#Start ligolo proxy
./proxy -selfcert -laddr 0.0.0.0:443

#Connect your agent here

#In ligolo shell
#Select session
ligolo-ng » session
? Specify a session : 1 - NT AUTHORITY\SYSTEM@WEB02 - 192.168.201.121:49789

#Start tunnel
[Agent : NT AUTHORITY\SYSTEM@WEB02] » start
[Agent : NT AUTHORITY\SYSTEM@WEB02] » INFO[0033] Starting tunnel to NT AUTHORITY\SYSTEM@WEB02

#create route to target subnet
sudo ip route add 172.16.124.0/24 dev ligolo
```

### Agent
```bash
.\agent.exe -connect 192.168.45.204:443 -ignore-cert
```

## [Diodon](https://github.com/diodon-dev/diodon)
Its a super helpful clipboard. Youre gonna want to have this in between copying and pasting hundreds of stuff during your exam. 
Personally, I binded the hot key to super(win key) + v to have it same as windows. 

## NetExec
This is a kali swiss army knife on steroids. You can enumerate, exploit on this AIO tool. Also, in case you are worried, I have verified that this is not an auto-exploit tool and is allowed during the exam. I used this extensively during my own exam. All the commands are in my cheat sheet.
### Installation
`sudo apt install netexec`

# [Handy Cheatsheet printer](materials/ref)
Yes you can just cat and grep your cheatsheets but why not replace $LHOST dynamically while you're at it?
Chmod this script as an executable and added it to PATH so that you can call it from anywhere.
Fyi, this was most most ran command during my exam.

## Pre-requisites
`pip install netifaces`
Change CHEATSHEET_PATH variable to whereever you decided to put your cheatsheet at

## Usage
`ref` - print cheatsheet, plug in tun0 or eth0 ip
`ref [keyword] [lines_after]`

## Example
`ref "===WINDOWS PE===" 40` - print windows priv esc section

# Quick Rev-shell generator
Minimal cli version of revshell.com. Also dynamically gets your tun0 or eth0 address.
Chmod this script as an executable and added it to PATH so that you can call it from anywhere.

## Pre-requisites
`pip install netifaces`

## Usage
`rs` - prints all rev shell types with default port and your tun0 or eth0 ip 
`rs [-t <shell_type>] [-i <INTERFACE>] [-p <LPORT>]` - specify your own variables
###Shell type values
powershell - `ps`
bash - `bash`
python - `python`
perl - `perl`
php - `php`
nc - `nc`

## Example
Generating your own ps64 revshell
`rs -t ps -i eth1 -p 80`


# [Quick transfer to windows target](materials/makepwn.py)
Python script to get your tun0 or eth0 ip, and then plug that into a ps1 script.
Run a command on your windows target upon gaining access to trigger the ps1 script and download all your crucial files to C:\Windows\Temp
