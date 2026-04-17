# Kali Linux Enhancement Plan
**Date:** 2026-04-14  
**System:** ashborn (Kali 2025.4)

---

## Pre-Installation Checklist
- [ ] Run `sudo apt update && sudo apt full-upgrade -y`
- [ ] Snapshot current package list: `dpkg --get-selections > ~/pre-install-packages.txt`
- [ ] Check available disk: 404 GB free — ample space
- [ ] Note: AMD Radeon PRO WX 3200 requires GPU driver setup (Phase 0)

---

## PHASE 0: Critical Infrastructure (Do First)

### 0.1 AMD GPU OpenCL Drivers for Hashcat
```bash
# Option A: ROCm (open source, recommended for Kali)
sudo apt install -y amdgpu-pro-opencl rocm-opencl-runtime clinfo
# OR Option B: Using AMD's direct ROCm install
wget -q -O - https://repo.radeon.com/rocm/rocm.gpg.key | sudo apt-key add -
echo 'deb [arch=amd64] https://repo.radeon.com/amdgpu/latest/ubuntu focal main' | sudo tee /etc/apt/sources.list.d/amdgpu.list
sudo apt update && sudo apt install rocm-opencl-runtime

# Verify: run hashcat benchmark
hashcat -b -d 2  # -d 2 should target AMD GPU
clinfo | grep "Device Type"
```
**Impact:** 10-50x speedup for password cracking vs CPU-only

### 0.2 Install Missing Kali Metapackages
```bash
sudo apt install -y kali-linux-web kali-linux-wireless kali-linux-forensics \
  kali-linux-pwtools kali-linux-crypto kali-linux-hardware kali-linux-exploit
```
**Note:** Will install ~500MB-2GB of additional tools. Review before running.

### 0.3 SecLists (Essential Wordlists)
```bash
sudo apt install -y seclists
# Installed to /usr/share/seclists/
# Key paths:
# /usr/share/seclists/Discovery/Web-Content/  — directory fuzzing
# /usr/share/seclists/Passwords/              — password lists
# /usr/share/seclists/Usernames/              — username lists
# /usr/share/seclists/Fuzzing/                — fuzzing payloads
```

---

## TIER 1: Essential — Install Immediately

### 1.1 nuclei (ProjectDiscovery)
**Why:** Industry-standard fast vulnerability scanner with 9000+ templates. Used in every bug bounty program.
```bash
# Method 1: apt (may be available)
sudo apt install -y nuclei

# Method 2: Go install
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Update templates after install
nuclei -update-templates
```
**Dependencies:** Go 1.21+  
**Disk:** ~200MB (with templates)

### 1.2 feroxbuster
**Why:** Fastest recursive directory/file discovery. Outperforms gobuster in recursive mode.
```bash
# Method 1: apt
sudo apt install -y feroxbuster

# Method 2: cargo
cargo install feroxbuster

# Method 3: binary release
curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash
```

### 1.3 ProjectDiscovery Suite (subfinder, dnsx, katana, gau, httpx-toolkit)
```bash
# These may already be in apt as part of kali
sudo apt install -y subfinder dnsx katana gau

# Or via Go:
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
```

### 1.4 volatility3
**Why:** volatility (v2) is deprecated. volatility3 is the current memory forensics standard.
```bash
sudo apt install -y python3-volatility3
# OR
pip3 install volatility3
# OR from source:
git clone https://github.com/volatilityfoundation/volatility3.git ~/tools/forensics/volatility3
cd ~/tools/forensics/volatility3 && pip3 install -r requirements.txt
```

### 1.5 ghidra
**Why:** NSA's open-source reverse engineering platform. Best free alternative to IDA Pro.
```bash
sudo apt install -y ghidra
# Or download from ghidra-sre.org
# Requires Java: sudo apt install -y default-jdk
```

### 1.6 kerbrute
**Why:** Essential for Active Directory testing — username enumeration and Kerberoasting.
```bash
sudo apt install -y kerbrute
# OR
go install github.com/ropnop/kerbrute@latest
```

### 1.7 chisel (Tunneling)
**Why:** HTTP/WebSocket TCP tunnel. Essential for pivoting through firewalls/proxies.
```bash
go install github.com/jpillora/chisel@latest
# Or download binary:
curl -sL https://github.com/jpillora/chisel/releases/latest/download/chisel_linux_amd64.gz | gunzip > ~/tools/exploit/chisel
chmod +x ~/tools/exploit/chisel
```

### 1.8 ligolo-ng (Advanced Tunneling)
**Why:** Superior to chisel for multi-hop pivoting. Agent-based, TUN interface.
```bash
# Download from releases
mkdir -p ~/tools/exploit/ligolo-ng
# Get latest from: https://github.com/nicocha30/ligolo-ng/releases
```

---

## TIER 2: Recommended — High Value Add

### 2.1 rustscan
**Why:** Scans all 65535 ports in ~1 second, passes results to nmap.
```bash
sudo apt install -y rustscan
# OR cargo:
cargo install rustscan
```

### 2.2 enum4linux-ng
**Why:** Modern Python rewrite of enum4linux with better output and LDAP support.
```bash
sudo apt install -y enum4linux-ng
# OR pip:
pip3 install enum4linux-ng
```

### 2.3 pwncat-cs
**Why:** Advanced reverse/bind shell handler — auto-upgrades to PTY, file upload/download, modules.
```bash
pip3 install pwncat-cs
# OR with pipx:
pipx install pwncat-cs
```

### 2.4 testssl.sh
**Why:** Comprehensive SSL/TLS testing. Used in web pentesting and cert audits.
```bash
sudo apt install -y testssl.sh
# OR:
git clone --depth 1 https://github.com/drwetter/testssl.sh.git ~/tools/web/testssl.sh
```

### 2.5 steghide
**Why:** Most common CTF steganography tool (JPEG/BMP/WAV/AU hiding).
```bash
sudo apt install -y steghide
```

### 2.6 pwndbg (GDB Plugin)
**Why:** Transforms GDB into a powerful exploit development environment.
```bash
git clone https://github.com/pwndbg/pwndbg ~/tools/re/pwndbg
cd ~/tools/re/pwndbg && ./setup.sh
```

### 2.7 BloodHound CE (Docker)
**Why:** BloodHound Community Edition with full graph database — bloodhound.py is only the ingestor.
```bash
sudo apt install -y docker.io docker-compose
# Use BloodHound CE docker-compose:
mkdir -p ~/tools/ad/bloodhound-ce
curl -L https://ghst.ly/getbhce -o ~/tools/ad/bloodhound-ce/docker-compose.yml
cd ~/tools/ad/bloodhound-ce && sudo docker-compose up -d
```

### 2.8 pwntools (Python Exploit Dev)
```bash
pip3 install pwntools
```

### 2.9 sliver (C2 Framework)
**Why:** Modern, open-source C2 framework. Actively maintained alternative to Empire.
```bash
# Download latest release binary
curl https://sliver.sh/install | sudo bash
```

### 2.10 waybackurls
```bash
go install github.com/tomnomnom/waybackurls@latest
```

### 2.11 gf (grep patterns for hackers)
```bash
go install github.com/tomnomnom/gf@latest
# Install patterns:
mkdir -p ~/.gf
git clone https://github.com/1ndianl33t/Gf-Patterns ~/.gf-patterns
cp ~/.gf-patterns/*.json ~/.gf/
```

### 2.12 qsreplace (Parameter manipulation)
```bash
go install github.com/tomnomnom/qsreplace@latest
```

---

## TIER 3: Specialized — Niche Use Cases

### 3.1 Binary Exploitation
```bash
sudo apt install -y python3-pwntools ropper one_gadget
pip3 install ROPgadget
```

### 3.2 Mobile Security
```bash
sudo apt install -y apktool jadx adb
pip3 install frida-tools objection
```

### 3.3 Cloud Security
```bash
# AWS
sudo apt install -y awscli
pip3 install pacu cloudsplaining prowler

# Azure
pip3 install roadrecon

# GCP
# Install gcloud SDK from official source

# Multi-cloud
pip3 install ScoutSuite
```

### 3.4 Kubernetes Security
```bash
go install sigs.k8s.io/kind@latest
sudo apt install -y kubectl
curl -sL https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.tar.gz | tar xz
```

### 3.5 SDR / RF
```bash
sudo apt install -y gqrx-sdr rtl-sdr gnuradio
```

### 3.6 Additional Forensics
```bash
sudo apt install -y foremost dcfldd ddrescue sleuthkit
pip3 install oletools
sudo apt install -y volatility3 rekall
```

### 3.7 Container Security
```bash
pip3 install docker-escape-tool
# CDK for container escape
go install github.com/cdk-team/CDK/cmd/cdk@latest
```

---

## Installation Order (Dependency-Aware)

```
Phase 0: AMD GPU drivers + Metapackages + SecLists
    ↓
Phase 1: System updates (apt full-upgrade)
    ↓
Phase 2: Go tools (nuclei, subfinder, dnsx, katana, kerbrute, chisel, waybackurls, gf)
    ↓
Phase 3: Apt packages (feroxbuster, rustscan, volatility3, ghidra, steghide, testssl.sh, enum4linux-ng)
    ↓
Phase 4: Pip packages (pwncat-cs, pwntools, cloud tools)
    ↓
Phase 5: Git clone tools (pwndbg, ligolo-ng)
    ↓
Phase 6: Docker services (BloodHound CE)
```

---

## Disk Space Budget

| Phase | Estimated Size |
|-------|---------------|
| Kali metapackages (web/wireless/forensics/etc) | ~2-4 GB |
| SecLists | ~1.5 GB |
| AMD GPU drivers / ROCm | ~1-3 GB |
| nuclei + templates | ~300 MB |
| Go tool binaries | ~500 MB |
| ghidra | ~1 GB (with JDK) |
| BloodHound CE (Docker) | ~2 GB |
| Other tools | ~500 MB |
| **Total estimate** | **~9-12 GB** |

**Available:** 404 GB — No disk concerns.

---

## Known Potential Conflicts

| Conflict | Details | Resolution |
|----------|---------|------------|
| Python versions | Some tools require specific Python versions | Use pipx for CLI tools |
| Go bin path | Go tools install to ~/go/bin — ensure in PATH | Add to ~/.zshrc |
| BloodHound versions | bloodhound.py (ingestor) vs BloodHound CE | Different purposes, compatible |
| Empire + Starkiller | Starkiller requires running Empire server | Start Empire first |
| AMD ROCm + kernel | ROCm may require specific kernel modules | Verify kernel compatibility |
