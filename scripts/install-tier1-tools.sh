#!/usr/bin/env bash
# =============================================================================
# Tier 1 Essential Tools Installation Script
# System: ashborn (Kali 2025.4)
# Date: 2026-04-14
# Run as: bash install-tier1-tools.sh
# =============================================================================

set -euo pipefail
LOG_FILE="$HOME/kali-enhancement-project/install-tier1.log"
TOOLS_DIR="$HOME/tools"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
ok()  { echo "[$(date '+%H:%M:%S')] ✅ $*" | tee -a "$LOG_FILE"; }
err() { echo "[$(date '+%H:%M:%S')] ❌ $*" | tee -a "$LOG_FILE"; }

mkdir -p "$TOOLS_DIR"/{recon,scanning,web,exploit,wireless,cloud,ad,mobile,forensics,automation,re}
log "Starting Tier 1 essential tools installation..."
log "Log: $LOG_FILE"

# -----------------------------------------------------------------------
# 0. Ensure Go is in PATH
# -----------------------------------------------------------------------
if ! command -v go &>/dev/null; then
  log "Installing Go..."
  sudo apt install -y golang-go
fi
export PATH="$PATH:$HOME/go/bin"
log "Go version: $(go version)"

# -----------------------------------------------------------------------
# 1. System update
# -----------------------------------------------------------------------
log "Running apt update..."
sudo apt update -qq

# -----------------------------------------------------------------------
# 2. SecLists — Essential wordlists
# -----------------------------------------------------------------------
log "Installing SecLists..."
if sudo apt install -y seclists 2>>"$LOG_FILE"; then
  ok "SecLists installed at /usr/share/seclists/"
else
  err "SecLists apt install failed — trying manual..."
  git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$TOOLS_DIR/recon/SecLists" 2>>"$LOG_FILE" && \
    ok "SecLists cloned to $TOOLS_DIR/recon/SecLists"
fi

# -----------------------------------------------------------------------
# 3. nuclei — Fast vulnerability scanner
# -----------------------------------------------------------------------
log "Installing nuclei..."
if sudo apt install -y nuclei 2>>"$LOG_FILE"; then
  ok "nuclei installed via apt: $(nuclei -version 2>&1 | head -1)"
else
  log "Trying go install for nuclei..."
  go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>>"$LOG_FILE" && \
    ok "nuclei installed via go: $(nuclei -version 2>&1 | head -1)" || err "nuclei install failed"
fi
# Update templates
log "Updating nuclei templates..."
nuclei -update-templates -silent 2>>"$LOG_FILE" || log "nuclei template update failed (non-fatal)"

# -----------------------------------------------------------------------
# 4. feroxbuster — Recursive web fuzzer
# -----------------------------------------------------------------------
log "Installing feroxbuster..."
if sudo apt install -y feroxbuster 2>>"$LOG_FILE"; then
  ok "feroxbuster installed: $(feroxbuster --version 2>&1 | head -1)"
else
  log "Trying binary install for feroxbuster..."
  curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh 2>>"$LOG_FILE" | \
    bash -s -- "$TOOLS_DIR/scanning" 2>>"$LOG_FILE" && \
    ok "feroxbuster installed to $TOOLS_DIR/scanning/" || err "feroxbuster install failed"
fi

# -----------------------------------------------------------------------
# 5. rustscan — Ultra-fast port scanner
# -----------------------------------------------------------------------
log "Installing rustscan..."
if sudo apt install -y rustscan 2>>"$LOG_FILE"; then
  ok "rustscan installed: $(rustscan --version 2>&1 | head -1)"
else
  # Try binary download
  RUSTSCAN_VER=$(curl -s https://api.github.com/repos/RustScan/RustScan/releases/latest | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null || echo "2.3.0")
  curl -sL "https://github.com/RustScan/RustScan/releases/download/${RUSTSCAN_VER}/rustscan_${RUSTSCAN_VER#v}_amd64.deb" \
    -o /tmp/rustscan.deb 2>>"$LOG_FILE" && \
    sudo dpkg -i /tmp/rustscan.deb 2>>"$LOG_FILE" && \
    ok "rustscan installed via deb" || err "rustscan install failed"
fi

# -----------------------------------------------------------------------
# 6. ProjectDiscovery Suite
# -----------------------------------------------------------------------
log "Installing ProjectDiscovery suite..."

PD_TOOLS=("subfinder" "dnsx" "katana" "httpx-toolkit")
for tool in "${PD_TOOLS[@]}"; do
  if sudo apt install -y "$tool" 2>>"$LOG_FILE"; then
    ok "$tool installed via apt"
  else
    log "$tool not in apt, trying go install..."
    case $tool in
      subfinder)    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>>"$LOG_FILE" ;;
      dnsx)         go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest 2>>"$LOG_FILE" ;;
      katana)       go install -v github.com/projectdiscovery/katana/cmd/katana@latest 2>>"$LOG_FILE" ;;
      httpx-toolkit) go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>>"$LOG_FILE" ;;
    esac && ok "$tool installed via go" || err "$tool install failed"
  fi
done

# gau
log "Installing gau (GetAllURLs)..."
go install -v github.com/lc/gau/v2/cmd/gau@latest 2>>"$LOG_FILE" && \
  ok "gau installed" || err "gau install failed"

# waybackurls
log "Installing waybackurls..."
go install -v github.com/tomnomnom/waybackurls@latest 2>>"$LOG_FILE" && \
  ok "waybackurls installed" || err "waybackurls install failed"

# gf (grep for hackers) + patterns
log "Installing gf..."
go install -v github.com/tomnomnom/gf@latest 2>>"$LOG_FILE" && ok "gf installed" || err "gf install failed"
mkdir -p ~/.gf
if [ ! -d ~/.gf-patterns ]; then
  git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns ~/.gf-patterns 2>>"$LOG_FILE" && \
    cp ~/.gf-patterns/*.json ~/.gf/ 2>/dev/null && ok "gf patterns installed" || err "gf patterns install failed"
fi

# -----------------------------------------------------------------------
# 7. kerbrute — Kerberos enumeration
# -----------------------------------------------------------------------
log "Installing kerbrute..."
if sudo apt install -y kerbrute 2>>"$LOG_FILE"; then
  ok "kerbrute installed via apt"
else
  go install -v github.com/ropnop/kerbrute@latest 2>>"$LOG_FILE" && \
    ok "kerbrute installed via go" || err "kerbrute install failed"
fi

# -----------------------------------------------------------------------
# 8. chisel — TCP tunneling over HTTP
# -----------------------------------------------------------------------
log "Installing chisel..."
go install -v github.com/jpillora/chisel@latest 2>>"$LOG_FILE" && \
  ok "chisel installed: $(chisel --version 2>&1 | head -1)" || err "chisel install failed"

# -----------------------------------------------------------------------
# 9. volatility3 — Memory forensics
# -----------------------------------------------------------------------
log "Installing volatility3..."
if sudo apt install -y python3-volatility3 2>>"$LOG_FILE"; then
  ok "volatility3 installed via apt"
elif pip3 install volatility3 2>>"$LOG_FILE"; then
  ok "volatility3 installed via pip3"
else
  git clone https://github.com/volatilityfoundation/volatility3.git "$TOOLS_DIR/forensics/volatility3" 2>>"$LOG_FILE" && \
    pip3 install -r "$TOOLS_DIR/forensics/volatility3/requirements.txt" 2>>"$LOG_FILE" && \
    ok "volatility3 cloned and deps installed" || err "volatility3 install failed"
fi

# -----------------------------------------------------------------------
# 10. ghidra — Reverse engineering
# -----------------------------------------------------------------------
log "Installing ghidra..."
sudo apt install -y default-jdk 2>>"$LOG_FILE" || log "JDK may already be installed"
if sudo apt install -y ghidra 2>>"$LOG_FILE"; then
  ok "ghidra installed via apt"
else
  err "ghidra not in apt — download manually from https://ghidra-sre.org/"
  log "Or run: sudo apt install -y ghidra (may need newer kali repos)"
fi

# -----------------------------------------------------------------------
# 11. steghide — Steganography
# -----------------------------------------------------------------------
log "Installing steghide..."
sudo apt install -y steghide 2>>"$LOG_FILE" && \
  ok "steghide installed" || err "steghide install failed"

# -----------------------------------------------------------------------
# 12. testssl.sh — SSL/TLS testing
# -----------------------------------------------------------------------
log "Installing testssl.sh..."
if sudo apt install -y testssl.sh 2>>"$LOG_FILE"; then
  ok "testssl.sh installed via apt"
else
  git clone --depth 1 https://github.com/drwetter/testssl.sh.git "$TOOLS_DIR/web/testssl.sh" 2>>"$LOG_FILE" && \
    sudo ln -sf "$TOOLS_DIR/web/testssl.sh/testssl.sh" /usr/local/bin/testssl.sh && \
    ok "testssl.sh cloned to $TOOLS_DIR/web/testssl.sh" || err "testssl.sh install failed"
fi

# -----------------------------------------------------------------------
# 13. enum4linux-ng — Modern enum4linux
# -----------------------------------------------------------------------
log "Installing enum4linux-ng..."
if sudo apt install -y enum4linux-ng 2>>"$LOG_FILE"; then
  ok "enum4linux-ng installed via apt"
else
  pip3 install enum4linux-ng 2>>"$LOG_FILE" && \
    ok "enum4linux-ng installed via pip3" || err "enum4linux-ng install failed"
fi

# -----------------------------------------------------------------------
# 14. pwntools — Exploit development
# -----------------------------------------------------------------------
log "Installing pwntools..."
pip3 install pwntools 2>>"$LOG_FILE" && \
  ok "pwntools installed" || err "pwntools install failed"

# -----------------------------------------------------------------------
# 15. pwncat-cs — Advanced shell handler
# -----------------------------------------------------------------------
log "Installing pwncat-cs..."
pip3 install pwncat-cs 2>>"$LOG_FILE" && \
  ok "pwncat-cs installed: $(pwncat-cs --version 2>&1 | head -1)" || err "pwncat-cs install failed"

# -----------------------------------------------------------------------
# 16. Kali metapackages
# -----------------------------------------------------------------------
log "Installing additional Kali metapackages..."
log "WARNING: This installs kali-linux-web, kali-linux-forensics, kali-linux-pwtools"
log "Estimated size: 2-4 GB. Ctrl+C to skip."
sleep 3
sudo apt install -y kali-linux-web kali-linux-forensics kali-linux-pwtools 2>>"$LOG_FILE" && \
  ok "Additional Kali metapackages installed" || err "Metapackage install had errors (check log)"

# -----------------------------------------------------------------------
# Update Go PATH in .zshrc
# -----------------------------------------------------------------------
if ! grep -q 'go/bin' ~/.zshrc 2>/dev/null; then
  echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.zshrc
  ok "Added ~/go/bin to PATH in ~/.zshrc"
fi

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
log ""
log "=============================="
log "  INSTALLATION COMPLETE"
log "=============================="
log ""
log "Checking installed tools:"
for t in nuclei feroxbuster rustscan subfinder dnsx katana gau waybackurls kerbrute chisel testssl.sh steghide enum4linux-ng; do
  if command -v "$t" &>/dev/null; then
    ok "$t — INSTALLED"
  else
    err "$t — NOT FOUND (check $LOG_FILE)"
  fi
done

log ""
log "Full log: $LOG_FILE"
log "Source your shell: source ~/.zshrc"
