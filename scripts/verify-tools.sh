#!/usr/bin/env bash
# =============================================================================
# Tool Verification Script — ashborn Kali 2025.4
# Checks status of all security tools (installed vs missing)
# =============================================================================

export PATH="$PATH:$HOME/go/bin:$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✅ INSTALLED${NC}  $1"; }
miss() { echo -e "${RED}❌ MISSING${NC}    $1"; }
warn() { echo -e "${YELLOW}⚠️  WARNING${NC}   $1"; }

chk() {
  local name="$1" cmd="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    ok "$name"
  else
    miss "$name"
  fi
}

echo "================================================="
echo "  KALI TOOL VERIFICATION — $(date '+%Y-%m-%d %H:%M')"
echo "  System: $(hostname) | $(uname -r)"
echo "================================================="
echo ""

echo "--- RECON & OSINT ---"
chk nmap; chk masscan; chk amass; chk theHarvester theharvester
chk recon-ng; chk dnsrecon; chk spiderfoot
chk subfinder; chk dnsx; chk httpx; chk katana; chk nuclei
chk gau; chk waybackurls; chk gf

echo ""
echo "--- WEB APPLICATION ---"
chk burpsuite; chk sqlmap; chk gobuster; chk ffuf; chk feroxbuster
chk dirb; chk wfuzz; chk nikto; chk wpscan; chk mitmproxy
chk testssl.sh testssl; chk sslscan

echo ""
echo "--- EXPLOITATION ---"
chk msfconsole; chk msfvenom; chk searchsploit

echo ""
echo "--- POST-EXPLOITATION & C2 ---"
chk "powershell-empire" powershell-empire
chk "evil-winrm" evil-winrm; chk "netexec/nxc" nxc
chk responder; chk sliver sliver-server

echo ""
echo "--- ACTIVE DIRECTORY ---"
chk "bloodhound-python" bloodhound-python
chk certipy certipy-ad 2>/dev/null || chk certipy certipy
chk enum4linux; chk enum4linux-ng; chk smbclient; chk smbmap
chk kerbrute; chk "pypykatz (pip)" pypykatz

echo ""
echo "--- PASSWORD ATTACKS ---"
chk hashcat; chk john; chk hydra; chk crunch

echo ""
echo "--- WIRELESS ---"
chk aircrack-ng; chk wifite; chk kismet

echo ""
echo "--- NETWORK ANALYSIS ---"
chk wireshark; chk tcpdump; chk scapy

echo ""
echo "--- TUNNELING & PIVOTING ---"
chk chisel; chk "ligolo-ng (proxy)" ligolo-proxy; chk "ligolo-ng (agent)" ligolo-agent

echo ""
echo "--- FORENSICS ---"
chk binwalk; chk exiftool; chk "volatility3 (vol)" vol
chk testdisk; chk foremost; chk steghide
chk pdf-parser pdf-parser

echo ""
echo "--- REVERSE ENGINEERING ---"
chk radare2 r2; chk gdb; chk ghidra
[ -f "$HOME/tools/re/pwndbg/gdbinit.py" ] && ok "pwndbg (GDB plugin loaded via ~/.gdbinit)" || miss "pwndbg"

echo ""
echo "--- EXPLOIT DEV ---"
chk pwntools python3 -c 'import pwn' 2>/dev/null || \
  (python3 -c 'import pwn' 2>/dev/null && ok "pwntools (python)" || miss "pwntools (python)")
chk pwncat-cs pwncat-cs 2>/dev/null

echo ""
echo "--- WORDLISTS ---"
[ -d /usr/share/seclists ] && ok "SecLists (/usr/share/seclists/)" || miss "SecLists"
[ -f /usr/share/wordlists/rockyou.txt.gz ] && ok "rockyou.txt.gz" || \
  ([ -f /usr/share/wordlists/rockyou.txt ] && ok "rockyou.txt (decompressed)" || miss "rockyou.txt")

echo ""
echo "--- GPU / HASHCAT OPENCL ---"
if RUSTICL_ENABLE=radeonsi clinfo 2>/dev/null | grep -q "Radeon\|radeonsi"; then
  ok "AMD GPU via Mesa rusticl (~2 GH/s MD5) — use: hashcat-gpu or hashcat -d 1"
elif clinfo 2>/dev/null | grep -q "AMD\|Radeon\|ROCm"; then
  ok "AMD OpenCL detected (GPU cracking enabled)"
elif clinfo 2>/dev/null | grep -q "PoCL\|cpu-"; then
  warn "Only PoCL/CPU OpenCL — run: sudo apt install mesa-opencl-icd rocm-opencl-icd"
else
  miss "OpenCL (clinfo not found or no platforms)"
fi


# =============================================================================
# TIER 2 (2026) — modern C2, cloud, supply-chain, AI-VR, DFIR, OPSEC, lab
# =============================================================================

echo ""
echo "--- C2 / POST-EX (TIER 2) ---"
chk sliver sliver-server
[ -d "$HOME/tools/Havoc" ] && ok "Havoc repo" || miss "Havoc repo"
chk evilginx2; chk merlin

echo ""
echo "--- AD 2026 ---"
chk coercer; chk ldeep; chk sccmhunter sccmhunter.py; chk certipy certipy
[ -d "$HOME/tools/krbrelayx" ] && ok "krbrelayx repo" || miss "krbrelayx repo"
[ -d "$HOME/tools/PKINITtools" ] && ok "PKINITtools repo" || miss "PKINITtools repo"
chk "bloodhound-ce collector" bloodhound-ce-python

echo ""
echo "--- CLOUD / K8S ---"
chk pacu; chk cloudfox; chk roadrecon; chk roadtx; chk azurehound
chk prowler; chk scoutsuite scout; chk kube-hunter; chk kubiscan

echo ""
echo "--- SUPPLY-CHAIN / CI ---"
chk gato-x gato-x; chk zizmor; chk semgrep

echo ""
echo "--- MOBILE / FUZZ ---"
chk frida; chk objection; chk apkleaks
chk afl-fuzz; chk honggfuzz

echo ""
echo "--- AI-ASSISTED VR ---"
chk vulnhuntr; chk hackingbuddygpt; chk pentestgpt
[ -d "/usr/local/lib/node_modules/@anthropic-ai/claude-agent-sdk" ] && ok "claude-agent-sdk (npm global)" || miss "claude-agent-sdk"

echo ""
echo "--- DEFENSE / DFIR ---"
chk osqueryi
chk log2timeline plaso-log2timeline
chk psort plaso-psort
chk capa; chk floss
[ -d "$HOME/tools/caldera" ] && ok "MITRE Caldera" || miss "MITRE Caldera"
[ -d "$HOME/tools/atomic-red-team" ] && ok "atomic-red-team repo" || miss "atomic-red-team"
docker image inspect mpepping/cyberchef >/dev/null 2>&1 && ok "cyberchef (docker)" || miss "cyberchef docker image"
docker image inspect opensecurity/mobile-security-framework-mobsf >/dev/null 2>&1 && ok "MobSF (docker)" || miss "MobSF docker image"

echo ""
echo "--- OPSEC / IDENTITY ---"
chk tor; chk torsocks; chk proxychains4; chk macchanger
chk wg wg; chk age; chk sops; chk direnv; chk firejail
chk axiom-scan 2>/dev/null; [ -d "$HOME/.axiom" ] && ok "axiom configured" || miss "axiom"

echo ""
echo "--- LAB / EMULATION ---"
chk virsh; chk virt-install; chk virt-manager
[ -d "$HOME/tools/GOAD" ] && ok "GOAD v3 repo" || miss "GOAD"
chk ludus
chk stratus

echo ""
echo "--- PRODUCTIVITY ---"
chk rustup; chk cargo; chk duckdb; chk usql; chk gron; chk mlr; chk yq; chk lnav; chk just

echo ""
echo "================================================="
echo "Run install-tier1-tools.sh or install-tier2-2026.sh for missing tools"
echo "================================================="
