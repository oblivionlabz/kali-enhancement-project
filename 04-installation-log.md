# Installation Log
**System:** ashborn (Kali 2025.4)  
**Audit Date:** 2026-04-14

---

## Status: Pre-Installation (Audit Complete)

No tools have been installed yet. Run the installation scripts after reviewing the enhancement plan.

---

## Pre-Install State
- **Packages installed:** 3,627
- **Kali metapackages:** kali-linux-core, kali-linux-default, kali-linux-headless, kali-linux-firmware
- **Disk used:** 17 GB / 451 GB (4%)
- **Snapshot:** `raw-data/installed-packages.txt`

---

## Recommended Installation Commands

### Step 1: System Update
```bash
sudo apt update && sudo apt full-upgrade -y
```

### Step 2: SecLists (Do This First)
```bash
sudo apt install -y seclists
```

### Step 3: Run Tier 1 Install Script
```bash
bash ~/kali-enhancement-project/scripts/install-tier1-tools.sh 2>&1 | tee ~/kali-enhancement-project/install-run-$(date +%Y%m%d).log
```

### Step 4: AMD GPU OpenCL (for hashcat)
```bash
# Check what's available
sudo apt-cache search rocm | head -20
sudo apt-cache search amdgpu | grep opencl

# Install if available
sudo apt install -y rocm-opencl-runtime
# OR
sudo apt install -y amdgpu-pro-opencl

# Verify
clinfo | grep -i "device type\|device name"
hashcat -b -d 2  # test AMD GPU
```

### Step 5: BloodHound CE (Docker)
```bash
sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker dxverm
newgrp docker
mkdir -p ~/tools/ad/bloodhound-ce && cd ~/tools/ad/bloodhound-ce
curl -L https://ghst.ly/getbhce -o docker-compose.yml
docker compose pull && docker compose up -d
# Access: http://localhost:8080 (admin/bloodhoundcommunityedition on first login)
```

### Step 6: pwndbg GDB Plugin
```bash
mkdir -p ~/tools/re
git clone https://github.com/pwndbg/pwndbg ~/tools/re/pwndbg
cd ~/tools/re/pwndbg && ./setup.sh
# Test: gdb → pwndbg> checksec
```

### Step 7: ligolo-ng
```bash
mkdir -p ~/tools/exploit/ligolo-ng
# Get latest from: https://github.com/nicocha30/ligolo-ng/releases
# Download: ligolo-ng_proxy_Linux_64bit.tar.gz + ligolo-ng_agent_Linux_64bit.tar.gz
LIGOLO_VER=$(curl -s https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
wget -O /tmp/ligolo-proxy.tar.gz "https://github.com/nicocha30/ligolo-ng/releases/download/${LIGOLO_VER}/ligolo-ng_proxy_Linux_64bit.tar.gz"
wget -O /tmp/ligolo-agent.tar.gz "https://github.com/nicocha30/ligolo-ng/releases/download/${LIGOLO_VER}/ligolo-ng_agent_Linux_64bit.tar.gz"
tar -xf /tmp/ligolo-proxy.tar.gz -C ~/tools/exploit/ligolo-ng/
tar -xf /tmp/ligolo-agent.tar.gz -C ~/tools/exploit/ligolo-ng/
chmod +x ~/tools/exploit/ligolo-ng/*
sudo ln -sf ~/tools/exploit/ligolo-ng/proxy /usr/local/bin/ligolo-proxy
```

---

## Post-Install Verification
```bash
bash ~/kali-enhancement-project/scripts/verify-tools.sh
```

---

## Notes
- Installation script logs are saved with timestamps
- If any tool fails, check the log at `~/kali-enhancement-project/install-tier1.log`
- After install, update PATH: `source ~/.zshrc`
