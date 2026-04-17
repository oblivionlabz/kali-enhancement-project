#!/usr/bin/env bash
# =============================================================================
# Update All Security Tools — ashborn Kali 2025.4
# Run periodically to keep tools current
# =============================================================================

set -euo pipefail
export PATH="$PATH:$HOME/go/bin"
LOG_FILE="$HOME/kali-enhancement-project/update-$(date +%Y%m%d).log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
ok()  { echo "[$(date '+%H:%M:%S')] ✅ $*" | tee -a "$LOG_FILE"; }

log "Starting full tool update — $(date)"
log "Log: $LOG_FILE"

# APT update
log "1/5 Updating apt packages..."
sudo apt update -qq 2>>"$LOG_FILE"
sudo apt full-upgrade -y 2>>"$LOG_FILE" && ok "APT packages updated"

# Go tools
log "2/5 Updating Go-installed tools..."
GO_TOOLS=(
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
  "github.com/projectdiscovery/katana/cmd/katana@latest"
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/lc/gau/v2/cmd/gau@latest"
  "github.com/tomnomnom/waybackurls@latest"
  "github.com/tomnomnom/gf@latest"
  "github.com/tomnomnom/qsreplace@latest"
  "github.com/ropnop/kerbrute@latest"
  "github.com/jpillora/chisel@latest"
)
for pkg in "${GO_TOOLS[@]}"; do
  tool=$(basename "$pkg" | cut -d@ -f1)
  go install -v "$pkg" 2>>"$LOG_FILE" && ok "Updated $tool" || log "Failed: $tool"
done

# Nuclei templates
log "3/5 Updating nuclei templates..."
command -v nuclei &>/dev/null && nuclei -update-templates -silent 2>>"$LOG_FILE" && ok "Nuclei templates updated"

# Python packages
log "4/5 Updating Python security packages..."
PY_TOOLS=("impacket" "scapy" "certipy-ad" "pypykatz" "lsassy" "dploot"
          "bloodhound" "mitmproxy" "pwncat-cs" "pwntools" "volatility3")
for pkg in "${PY_TOOLS[@]}"; do
  pip3 install --upgrade --quiet "$pkg" 2>>"$LOG_FILE" && ok "Updated $pkg" || log "Skipping $pkg (may not be installed)"
done

# Wpscan DB update
log "5/5 Updating wpscan database..."
command -v wpscan &>/dev/null && wpscan --update 2>>"$LOG_FILE" && ok "wpscan DB updated" || true

# searchsploit update
log "Updating exploit-db..."
sudo apt install -y exploitdb 2>>"$LOG_FILE" && searchsploit -u 2>>"$LOG_FILE" && ok "exploitdb updated" || true

log ""
log "=============================="
log "  UPDATE COMPLETE — $(date)"
log "=============================="
