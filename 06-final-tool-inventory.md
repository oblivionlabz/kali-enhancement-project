# Final Tool Inventory
**Date:** 2026-04-14 | **System:** ashborn (Kali 2025.4)

---

## INSTALLED & WORKING

### Reconnaissance & OSINT
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| nmap | 7.95 | /usr/bin/nmap | NSE scripts at /usr/share/nmap/ |
| masscan | 1.3.2 | /usr/bin/masscan | Requires root |
| amass | 5.0.1 | /usr/bin/amass | |
| theHarvester | 4.8.2 | /usr/bin/theHarvester | |
| recon-ng | 5.1.2 | /usr/bin/recon-ng | |
| dnsrecon | 1.3.1 | /usr/bin/dnsrecon | |
| spiderfoot | 4.0 | /usr/bin/spiderfoot | Web UI available |
| httpx | present | /usr/bin/httpx | |

### Web Application
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| Burp Suite CE | 2025.10.6 | /usr/bin/burpsuite | Community Edition |
| sqlmap | 1.9.11 | /usr/bin/sqlmap | |
| gobuster | 3.8.0 | /usr/bin/gobuster | |
| ffuf | 2.1.0 | /usr/bin/ffuf | |
| wfuzz | 3.1.0 | /usr/bin/wfuzz | |
| dirb | 2.22 | /usr/bin/dirb | |
| nikto | 2.5.0 | /usr/bin/nikto | |
| wpscan | 3.8.28 | /usr/bin/wpscan | Requires API key for vuln DB |
| mitmproxy | 12.2.0 | pip3 | |

### Exploitation
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| Metasploit Framework | 6.4.99 | /usr/bin/msfconsole | |
| msfpc | 1.4.5 | /usr/bin/msfpc | MSFvenom helper |
| searchsploit | 20251101 | /usr/bin/searchsploit | exploitdb at /usr/share/exploitdb/ |
| impacket-scripts | 0.13.0 | /usr/bin/impacket-* | Full suite |

### Post-Exploitation & C2
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| PowerShell Empire | 6.2.1 | /usr/bin/powershell-empire | Run server first |
| Starkiller | 3.1.0 | /usr/bin/starkiller | Empire web UI |
| evil-winrm | 3.7 | /usr/bin/evil-winrm | |
| netexec / nxc | 1.4.0 | /usr/bin/netexec | |
| responder | 3.1.7 | /usr/bin/responder | Requires root |
| mimikatz | 2.2.0 | /usr/share/windows-resources/mimikatz/ | Windows binary |
| PowerSploit | 3.0.0 | /usr/share/powersploit/ | PS scripts |

### Active Directory
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| bloodhound.py | 1.9.0 | pip3 | Ingestor only (no GUI) |
| certipy-ad | 5.0.3 | pip3 | AD CS attacks |
| pypykatz | 0.6.10 | pip3 | Mimikatz in Python |
| lsassy | 3.1.11 | pip3 | Remote LSASS dump |
| dploot | 3.1.2 | pip3 | DPAPI looting |
| ldapdomaindump | 0.9.4 | pip3 | AD LDAP dump |
| enum4linux | 0.9.1 | /usr/bin/enum4linux | |
| smbclient | 4.23.3 | /usr/bin/smbclient | |
| smbmap | present | /usr/bin/smbmap | |

### Password Attacks
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| hashcat | 7.1.2 | /usr/bin/hashcat | GPU: CPU-only (missing AMD OpenCL) |
| john (Jumbo) | 1.9.0 | /usr/bin/john | |
| hydra | 9.6 | /usr/bin/hydra | |
| crunch | 3.6 | /usr/bin/crunch | Wordlist generator |
| rockyou.txt.gz | — | /usr/share/wordlists/ | Main wordlist |

### Wireless
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| aircrack-ng | 1.7 | /usr/bin/aircrack-ng | Monitor mode supported |
| wifite | 2.7.0 | /usr/bin/wifite | |
| kismet | 2025.09.R1 | /usr/bin/kismet | Full wireless IDS suite |

### Network Analysis
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| wireshark | 4.6.0 | /usr/bin/wireshark | Can run without root (wireshark group) |
| tcpdump | present | /usr/bin/tcpdump | |
| scapy | 2.6.1 | pip3 | |

### Forensics
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| binwalk | present | /usr/bin/binwalk | |
| exiftool | present | /usr/bin/exiftool | |
| autopsy | 2.24 | /usr/bin/autopsy | Old GUI, functional |
| testdisk | 7.2 | /usr/bin/testdisk | |
| pdf-parser | 0.7.13 | /usr/bin/pdf-parser | |
| pdfid | 0.2.10 | /usr/bin/pdfid | |
| yara | 4.5.4 | pip3+lib | |

### Reverse Engineering
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| radare2 | 6.0.5 | /usr/bin/radare2 | r2 command |
| gdb | present | /usr/bin/gdb | No pwndbg/peda installed |

### Social Engineering
| Tool | Version | Location | Notes |
|------|---------|----------|-------|
| SET (setoolkit) | 8.0.3 | /usr/bin/setoolkit | |
| gophish | 0.12.1 | /usr/bin/gophish | |

---

## NOT INSTALLED — HIGH PRIORITY

| Tool | Category | Install Method | Priority |
|------|----------|---------------|---------|
| nuclei | Vuln scanning | apt / go install | 🔴 Critical |
| feroxbuster | Web fuzzing | apt / cargo | 🔴 Critical |
| subfinder | Recon | apt / go install | 🔴 Critical |
| volatility3 | Memory forensics | apt / pip3 | 🔴 Critical |
| ghidra | Reverse engineering | apt / manual | 🔴 Critical |
| AMD OpenCL/ROCm | GPU cracking | amdgpu-pro | 🔴 Critical |
| SecLists | Wordlists | apt | 🔴 Critical |
| kerbrute | AD/Kerberos | apt / go install | 🔴 Critical |
| chisel | Tunneling | go install | 🔴 Critical |
| ligolo-ng | Tunneling/pivot | binary release | 🟠 High |
| rustscan | Port scanning | apt / cargo | 🟠 High |
| enum4linux-ng | AD enumeration | apt / pip3 | 🟠 High |
| pwncat-cs | Shell handling | pip3 | 🟠 High |
| testssl.sh | SSL testing | apt | 🟠 High |
| steghide | Steganography | apt | 🟠 High |
| pwndbg | Exploit dev | git+setup | 🟠 High |
| BloodHound CE | AD visualization | docker-compose | 🟠 High |
| katana | Web crawling | apt / go | 🟡 Medium |
| dnsx | DNS toolkit | apt / go | 🟡 Medium |
| gau/waybackurls | URL gathering | go install | 🟡 Medium |
| pwntools | Exploit dev | pip3 | 🟡 Medium |
| sliver | C2 framework | binary | 🟡 Medium |
| ScoutSuite | Cloud security | pip3 | 🟡 Medium |
| frida/objection | Mobile | pip3 | 🟡 Medium |

---

## WORDLISTS STATUS

| Wordlist | Location | Status |
|----------|----------|--------|
| rockyou.txt.gz | /usr/share/wordlists/ | ✅ Present (compressed) |
| fasttrack.txt | /usr/share/wordlists/ | ✅ Present |
| john.lst | /usr/share/wordlists/ | ✅ Present |
| dirb wordlists | /usr/share/dirb/ | ✅ Present |
| wfuzz wordlists | /usr/share/wfuzz/ | ✅ Present |
| metasploit wordlists | /usr/share/wordlists/metasploit/ | ✅ Present |
| SecLists | — | ❌ **NOT INSTALLED** |
| fuzzdb | — | ❌ Not installed |

> ⚠️ **SecLists is missing** — This is the most comprehensive wordlist collection used in modern pentesting.
> Install: `sudo apt install -y seclists`
