# Kali Linux Security Environment Audit Report
**Date:** 2026-04-14  
**System:** ashborn  
**Analyst:** Automated Audit via Claude Code

---

## 1. Executive Summary

| Category | Status | Score |
|----------|--------|-------|
| OS & Kernel | ✅ Current (2025.4, kernel 6.16.8) | 9/10 |
| Hardware | ✅ Strong (32GB RAM, NVMe, dual GPU) | 9/10 |
| Storage | ✅ Abundant (404GB free) | 10/10 |
| Network Security | ✅ Minimal attack surface (no open ports) | 9/10 |
| Tool Coverage | ⚠️ Good default set, missing modern tools | 6/10 |
| Firewall | ⚠️ No active firewall (ufw inactive, no iptables rules) | 4/10 |
| GPU/Hashcat | ⚠️ AMD GPU present but no native OpenCL drivers | 5/10 |
| Wireless | ✅ Monitor mode supported | 8/10 |

**Overall Security Posture Score: 7.5/10**

### Critical Gaps
1. **No active firewall** — ufw inactive, iptables empty. Outbound connections unrestricted.
2. **AMD GPU lacks native OpenCL** — Only PoCL (CPU-emulated OpenCL), missing ROCm/AMDGPU-PRO for GPU-accelerated cracking.
3. **Missing modern toolchain** — nuclei, feroxbuster, rustscan, ProjectDiscovery suite, volatility3, ghidra, ligolo-ng, sliver absent.
4. **Only kali-linux-default metapackage** — Missing specialized metapackages (web, wireless, forensics, exploit, pwtools).
5. **No wordlist expansion** — Only rockyou.gz present; no SecLists, no custom wordlists for web fuzzing.

---

## 2. System Profile

### 2.1 Operating System
| Parameter | Value |
|-----------|-------|
| Distribution | Kali GNU/Linux Rolling |
| Version | 2025.4 |
| Codename | kali-rolling |
| Kernel | 6.16.8+kali-amd64 |
| Kernel Build | Kali 6.16.8-1kali1 (2025-09-24) |
| Architecture | x86_64 |
| Compiler | gcc-14 (Debian 14.3.0-8) |
| Hostname | ashborn |
| Uptime | ~12 min at audit time |
| Last Boot | 2026-04-14 01:06 |

### 2.2 Hardware
| Component | Details |
|-----------|---------|
| CPU | Intel Core i7-8565U @ 1.80GHz (Whiskey Lake-U) |
| Cores/Threads | 4 cores / 8 threads |
| CPU Max Freq | 4.60 GHz (turbo) |
| L3 Cache | 8 MiB |
| Virtualization | VT-x supported (bare metal — `systemd-detect-virt` = `none`) |
| RAM | 32 GB total (30 GB shown, ~27 GB available) |
| Swap | 24 GB (LVM) |
| Primary Storage | 476.9 GB NVMe SSD (nvme0n1) |
| Root Partition | 451 GB LVM ext4 — **17 GB used / 404 GB free (4%)** |
| Boot | 944 MB ext4 at /boot (227MB used) |
| EFI | 975 MB vfat at /boot/efi (304KB used) |
| GPU 1 | Intel UHD Graphics 620 (WhiskeyLake-U GT2) |
| GPU 2 | AMD Radeon PRO WX 3200 (Lexa XT) — **Dedicated GPU** |
| OpenCL | PoCL only (CPU emulation) — AMD GPU driver missing |

### 2.3 CPU Vulnerability Status
| Vulnerability | Status |
|--------------|--------|
| Spectre v1 | Mitigated |
| Spectre v2 | Mitigated (Enhanced IBRS) |
| Meltdown | Not affected |
| MDS | Not affected |
| Retbleed | Mitigated |
| Spec Store Bypass | Mitigated via prctl |
| MMIO Stale Data | Mitigated (Clear CPU buffers) |
| L1TF | Not affected |

### 2.4 Network Configuration
| Interface | State | IP Address | MAC |
|-----------|-------|------------|-----|
| lo | UP | 127.0.0.1/8 | 00:00:00:00:00:00 |
| eth0 | DOWN | — | AA:BB:CC:DD:EE:01 |
| wlan0 | UP | 192.168.0.100/24 (DHCP) | AA:BB:CC:DD:EE:02 |

**IPv6 (wlan0):** 2601:240:8400:ef00::ae2f/128 (global, dynamic)  
**Default Gateway:** 192.168.0.1 via wlan0  
**DNS:** 75.75.75.75, 75.75.76.76 (Comcast/Xfinity resolvers)  
**Wireless:** Monitor mode supported  

### 2.5 Active Services (Running)
| Service | Purpose | Notes |
|---------|---------|-------|
| accounts-daemon | Accounts Service | Normal |
| bolt | Thunderbolt system service | Normal |
| cron | Scheduled tasks | Normal |
| dbus | D-Bus message bus | Normal |
| haveged | Entropy daemon | Good for crypto |
| ModemManager | Modem management | Normal |
| NetworkManager | Network management | Normal |
| polkit | Authorization manager | Normal |
| power-profiles-daemon | Power management | Normal |
| sddm | Display manager (KDE) | Normal |
| smartmontools | Disk health monitoring | Good |
| systemd-timesyncd | Time synchronization | Normal |
| wpa_supplicant | WiFi authentication | Normal |

**No unexpected services. Minimal attack surface.**

### 2.6 Firewall Status
- **ufw:** Inactive
- **iptables:** No rules (ACCEPT all)
- **nftables:** No ruleset
- **Open listening ports:** Only DHCPv6 client (udp/546)

> ⚠️ **No firewall active.** While this is common for a pentesting machine, consider enabling basic egress filtering.

### 2.7 User & Permissions
| User | UID | Shell | Groups |
|------|-----|-------|--------|
| root | 0 | /usr/bin/zsh | root |
| dxverm | 1000 | /usr/bin/zsh | dxverm, adm, dialout, cdrom, floppy, sudo, audio, dip, video, plugdev, users, netdev, bluetooth, lpadmin, **wireshark**, **kaboxer** |
| postgres | 117 | /bin/bash | PostgreSQL service |

**Key group memberships:**
- `sudo` — Full sudo access
- `wireshark` — Can capture without root
- `kaboxer` — Kali app container support
- `dialout` — Serial/USB device access (good for hardware hacking)

---

## 3. Security Tool Inventory

### 3.1 Installed Tools Matrix

| Category | Tool | Version | Status |
|----------|------|---------|--------|
| **Recon/OSINT** | amass | 5.0.1 | ✅ Current |
| | theHarvester | 4.8.2 | ✅ Current |
| | recon-ng | 5.1.2 | ✅ Current |
| | dnsrecon | 1.3.1 | ✅ Current |
| | spiderfoot | 4.0 | ✅ Current |
| **Scanning** | nmap | 7.95 | ✅ Current |
| | masscan | 1.3.2 | ✅ Current |
| | httpx | installed | ✅ Present |
| | nikto | 2.5.0 | ✅ Current |
| | skipfish | 2.10b | ⚠️ Aging |
| **Web App** | Burp Suite CE | 2025.10.6 | ✅ Latest CE |
| | sqlmap | 1.9.11 | ✅ Current |
| | gobuster | 3.8.0 | ✅ Current |
| | ffuf | 2.1.0 | ✅ Current |
| | dirb | 2.22 | ✅ Present |
| | dirbuster | 1.0 | ⚠️ Outdated (abandoned) |
| | wfuzz | 3.1.0 | ✅ Present |
| | wpscan | 3.8.28 | ✅ Current |
| **Exploitation** | Metasploit Framework | 6.4.99 | ✅ Current |
| | msfpc | 1.4.5 | ✅ Present |
| | exploitdb/searchsploit | 20251101 | ✅ Current |
| | impacket-scripts | 0.13.0 | ✅ Current |
| **Post-Exploitation** | PowerShell Empire | 6.2.1 | ✅ Current |
| | Starkiller (Empire UI) | 3.1.0 | ✅ Current |
| | PowerSploit | 3.0.0 | ⚠️ Archived |
| | evil-winrm | 3.7 | ✅ Current |
| | mimikatz | 2.2.0 | ✅ Present |
| | netexec/nxc | 1.4.0 | ✅ Current |
| | responder | 3.1.7 | ✅ Current |
| **Password** | hashcat | 7.1.2 | ✅ Current |
| | john (Jumbo) | 1.9.0 | ⚠️ Aging |
| | hydra | 9.6 | ✅ Current |
| | crunch | 3.6 | ✅ Present |
| **AD/LDAP** | bloodhound.py | 1.9.0 | ✅ Current |
| | enum4linux | 0.9.1 | ✅ Present |
| | smbclient | 4.23.3 | ✅ Current |
| | smbmap | installed | ✅ Present |
| | ldap-utils | 2.6.10 | ✅ Current |
| | ldapdomaindump (py3) | 0.9.4 | ✅ Present |
| | certipy-ad | 5.0.3 | ✅ Current |
| | pypykatz | 0.6.10 | ✅ Current |
| | lsassy | 3.1.11 | ✅ Present |
| | dploot | 3.1.2 | ✅ Present |
| **Wireless** | aircrack-ng | 1.7 | ✅ Current |
| | wifite | 2.7.0 | ✅ Current |
| | kismet | 2025.09.R1 | ✅ Current |
| **Network Analysis** | wireshark | 4.6.0 | ✅ Current |
| | mitmproxy | 12.2.0 | ✅ Current |
| | scapy | 2.6.1 | ✅ Current |
| **Forensics** | autopsy | 2.24 | ⚠️ Old GUI |
| | binwalk | installed | ✅ Present |
| | exiftool | installed | ✅ Present |
| | testdisk/photorec | 7.2 | ✅ Current |
| | pdf-parser | 0.7.13 | ✅ Present |
| | pdfid | 0.2.10 | ✅ Present |
| | yara (python3) | 4.5.4 | ✅ Current |
| **Reverse Engineering** | radare2 | 6.0.5 | ✅ Current |
| | gdb | installed | ✅ Present |
| **Social Engineering** | SET | 8.0.3 | ✅ Current |
| | gophish | 0.12.1 | ✅ Present |
| **Cloud** | shodan (python) | 1.31.0 | ✅ Present |
| | censys (python) | 2.2.18 | ✅ Present |
| **PowerShell** | PowerShell Core | 7.5.4 | ✅ Current |

### 3.2 Installed Kali Metapackages
- `kali-linux-core` — Core system
- `kali-linux-default` — Default desktop tools
- `kali-linux-headless` — Headless/CLI tools
- `kali-linux-firmware` — Hardware firmware

**Missing metapackages** (see Enhancement Plan):
- `kali-linux-web` — Web application testing
- `kali-linux-wireless` — Full wireless suite
- `kali-linux-forensics` — Full forensics suite
- `kali-linux-exploit` — Exploitation tools
- `kali-linux-pwtools` — Password attack tools
- `kali-linux-crypto` — Cryptography tools
- `kali-linux-hardware` — Hardware hacking

---

## 4. Critical Gaps & Recommendations

### HIGH PRIORITY
1. **AMD GPU OpenCL drivers** — Install ROCm or amdgpu-pro for GPU-accelerated hashcat (~10-50x speedup)
2. **nuclei** — Industry-standard fast vulnerability scanner, not in default Kali
3. **feroxbuster** — More powerful than gobuster/ffuf for recursive fuzzing
4. **ProjectDiscovery suite** — subfinder, dnsx, katana, gau (passive recon)
5. **volatility3** — Memory forensics (volatility is abandoned, v3 is the current tool)
6. **ghidra** — NSA's free RE platform, rivals IDA Pro
7. **SecLists** — Comprehensive wordlist collection for all testing phases
8. **ligolo-ng** — Modern, fast tunneling/pivoting tool
9. **chisel** — HTTP-based tunneling essential for C2 over restricted networks
10. **kerbrute** — Kerberos enumeration/bruteforce (essential for AD testing)

### MEDIUM PRIORITY
1. rustscan — Fast port scanning pre-nmap
2. enum4linux-ng — Modern rewrite of enum4linux
3. pwncat-cs — Advanced shell handler with auto-upgrade
4. testssl.sh — SSL/TLS configuration auditing
5. steghide — Steganography (CTF essential)
6. pwndbg — GDB plugin for exploit development
7. BloodHound CE (Docker) — Upgrade from bloodhound.py ingestor only
8. sliver — Modern C2 alternative to Empire

### LOWER PRIORITY
1. Additional Kali metapackages for coverage
2. Docker for isolated tool environments
3. Wordlist expansion (custom, targeted)

---

## 5. Raw Data References
- Hardware info: `raw-data/hardware-info.txt`
- Network config: `raw-data/network-config.txt`
- Installed packages: `raw-data/installed-packages.txt`
