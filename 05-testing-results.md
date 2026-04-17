# Testing Results
**System:** ashborn (Kali 2025.4)  
**Date:** 2026-04-14

---

## Pre-Installation Verification (Baseline)

### Summary
- **Tools INSTALLED:** 30 / 50 checked (60%)
- **Tools MISSING:** 20 / 50 critical tools absent
- **Overall Readiness:** Good baseline, missing modern ecosystem tools

### Results by Category

| Category | Installed | Missing | Coverage |
|----------|-----------|---------|---------|
| Recon & OSINT | nmap, masscan, amass, theHarvester, recon-ng, dnsrecon, spiderfoot, httpx | subfinder, dnsx, katana, nuclei, gau, waybackurls, gf | 53% |
| Web App | burpsuite, sqlmap, gobuster, ffuf, dirb, wfuzz, nikto, wpscan, mitmproxy, sslscan | feroxbuster, testssl.sh | 83% |
| Exploitation | msfconsole, msfvenom, searchsploit | — | 100% |
| Post-Exploit/C2 | empire, evil-winrm, nxc, responder | sliver | 80% |
| Active Directory | bloodhound.py, certipy, enum4linux, smbclient, smbmap, pypykatz | enum4linux-ng, kerbrute | 75% |
| Password | hashcat, john, hydra, crunch | (GPU acceleration) | 90% |
| Wireless | aircrack-ng, wifite, kismet | — | 100% |
| Network Analysis | wireshark, tcpdump, scapy | — | 100% |
| Tunneling | — | chisel, ligolo-ng | 0% |
| Forensics | binwalk, exiftool, testdisk | volatility3, steghide, foremost | 40% |
| Reverse Eng | radare2, gdb | ghidra, pwndbg | 50% |
| Exploit Dev | pwntools | pwncat-cs | 50% |
| Wordlists | rockyou.txt.gz | SecLists | 40% |
| GPU/OpenCL | (PoCL CPU) | AMD ROCm | 0% |

---

## Critical Findings

### 1. GPU Cracking Severely Limited
- AMD Radeon PRO WX 3200 is present but only running PoCL (CPU emulation)
- hashcat runs in CPU mode — roughly 10-50x slower than GPU mode
- **Fix:** Install AMD ROCm OpenCL runtime

### 2. No Tunneling/Pivoting Capability
- chisel and ligolo-ng are both absent
- This is a significant gap for multi-hop engagements
- **Fix:** `go install github.com/jpillora/chisel@latest`

### 3. Modern Web Recon Stack Missing
- The ProjectDiscovery ecosystem (subfinder, dnsx, katana, nuclei) is entirely absent
- These tools are now standard in bug bounty and pentest workflows
- **Fix:** See install-tier1-tools.sh

### 4. Memory Forensics Gap
- volatility3 not installed (volatility2 deprecated)
- No steghide, foremost for CTF/forensics work
- **Fix:** `sudo apt install volatility3 steghide foremost`

### 5. No Active Wordlist Collection
- Only rockyou.txt.gz (password cracking) is present
- No SecLists for web fuzzing, username enumeration, etc.
- **Fix:** `sudo apt install seclists`

---

## Working Tool Confirmations

All of the following have been confirmed present on system:

```
✅ nmap 7.95          ✅ Metasploit 6.4.99   ✅ hashcat 7.1.2
✅ Burp Suite CE      ✅ sqlmap 1.9.11        ✅ hydra 9.6
✅ aircrack-ng 1.7    ✅ kismet 2025.09.R1    ✅ wifite 2.7
✅ wireshark 4.6.0    ✅ netexec 1.4.0        ✅ responder 3.1.7
✅ evil-winrm 3.7     ✅ radare2 6.0.5        ✅ certipy-ad 5.0.3
✅ pypykatz 0.6.10    ✅ bloodhound.py 1.9.0  ✅ mitmproxy 12.2.0
✅ gobuster 3.8.0     ✅ ffuf 2.1.0           ✅ nikto 2.5.0
✅ PowerShell 7.5.4   ✅ Empire 6.2.1         ✅ searchsploit
```

---

## Post-Install Testing (To Be Completed)
After running install-tier1-tools.sh, verify:
- [ ] `nuclei -version`
- [ ] `feroxbuster --version`
- [ ] `subfinder -version`
- [ ] `rustscan --version`
- [ ] `kerbrute version`
- [ ] `chisel --version`
- [ ] `volatility3 -h`
- [ ] `steghide --version`
- [ ] `testssl.sh --version`
- [ ] `hashcat -b -d 2` (AMD GPU benchmark — after ROCm install)
- [ ] `seclists` wordlist accessible at `/usr/share/seclists/`
