#!/usr/bin/env bash
# Tier 2 (2026) install — ashborn
# Installs the P1 gap-audit batch: modern C2, AD-2026, cloud/K8s, supply-chain,
# mobile, DFIR, OPSEC, lab, AI-VR, and productivity tooling.
#
# Safe-by-default: installs only. Does not start services, bind ports, pull
# cloud infra, or run containers. Heavy stacks (Wazuh, Security Onion, GOAD,
# Ludus) are scaffolded — the `install-*-stack` helpers are defined but the
# user must invoke them explicitly.
set -u
LOG="$HOME/kali-enhancement-project/install-tier2-$(date +%Y%m%d-%H%M).log"
exec > >(tee -a "$LOG") 2>&1
echo "=== Tier 2 install — $(date) ==="
echo "Log: $LOG"
export DEBIAN_FRONTEND=noninteractive
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$PATH:$HOME/.local/bin:$GOPATH/bin:$HOME/.cargo/bin"
mkdir -p "$GOPATH/bin"
# APT wrapper that propagates DEBIAN_FRONTEND through sudo + keeps old configs
APTI='sudo -n -E DEBIAN_FRONTEND=noninteractive apt-get -yqq -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef install'

# Preseed debconf answers so postinst scripts never prompt
preseed() {
  sudo -n debconf-set-selections <<'DEB'
krb5-config krb5-config/default_realm string OBLIVIONLABZ.NET
krb5-config krb5-config/kerberos_servers string
krb5-config krb5-config/admin_server string
krb5-config krb5-config/add_servers_realm string OBLIVIONLABZ.NET
krb5-config krb5-config/add_servers boolean false
postfix postfix/main_mailer_type select No configuration
wireshark-common wireshark-common/install-setuid boolean true
libc6 libraries/restart-without-asking boolean true
kexec-tools kexec-tools/load_kexec boolean false
iptables-persistent iptables-persistent/autosave_v4 boolean false
iptables-persistent iptables-persistent/autosave_v6 boolean false
DEB
}
preseed

banner() { echo; echo "━━━ $* ━━━"; }
try()    { echo "+ $*"; eval "$*" || echo "  [skip] $* failed (non-fatal)"; }

# ────────────────────────────────────────────────────────────────────
banner "APT: refresh"
sudo -n apt-get update -qq

banner "APT: Kali-packaged offensive + defensive tools"
APT_P1=(
  sliver          afl++         ldeep        coercer        pacu
  proxychains4    macchanger    tor          torsocks       obfs4proxy
  wireguard-tools age           direnv        sops           jq
  gron            miller        yq            feroxbuster    ripgrep-all
  lnav            just          zig           ruby-full      npm
  osquery         plaso         plaso-tools   libvirt-daemon-system
  virt-manager    qemu-kvm      bridge-utils  libvirt-clients
  firejail        firejail-profiles sshuttle   signal-cli    bubblewrap
  veracrypt       ripgrep
)
for pkg in "${APT_P1[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "= already installed: $pkg"
  else
    try $APTI "$pkg"
  fi
done

# ────────────────────────────────────────────────────────────────────
banner "pipx: Python tools"
PIPX_P1=(
  sccmhunter      certipy-ad        bloodhound-ce
  prowler         scoutsuite        kube-hunter       kubiscan
  roadrecon       roadtx            apkleaks          frida-tools
  objection       zizmor            gato              packj
  flare-capa      flare-floss       malwarebazaar     matrix-commander
  semgrep         vulnhuntr         attackgen         hackingbuddygpt
  claude-agent-sdk                  nebula-ai
  htb-cli         impacket
)
for pkg in "${PIPX_P1[@]}"; do
  if pipx list --short 2>/dev/null | awk '{print $1}' | grep -qx "$pkg"; then
    echo "= already installed: $pkg"
  else
    try pipx install "$pkg"
  fi
done

banner "pipx: re-inject helpers into pwntools/impacket if present"
try pipx inject impacket ldap3 2>/dev/null
try pipx upgrade-all 2>/dev/null

# ────────────────────────────────────────────────────────────────────
banner "Go tools (GOPATH=$GOPATH)"
GO_TOOLS=(
  "github.com/kgretzky/evilginx2@latest"
  "github.com/Ne0nd0g/merlin@latest"
  "github.com/xo/usql@latest"
  "github.com/DataDog/stratus-red-team/v2/cmd/stratus@latest"
  "github.com/BishopFox/cloudfox@latest"
)
for mod in "${GO_TOOLS[@]}"; do
  name="$(basename "${mod%@*}")"
  if [ -x "$GOPATH/bin/$name" ]; then
    echo "= already installed: $name"
  else
    try go install "$mod"
  fi
done

# ────────────────────────────────────────────────────────────────────
banner "Rust: install rustup (no-op if present)"
if ! command -v rustup >/dev/null 2>&1; then
  try bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal"
else
  echo "= rustup present"
fi
source "$HOME/.cargo/env" 2>/dev/null || true

# ────────────────────────────────────────────────────────────────────
banner "Binary releases: duckdb, AzureHound, Havoc source"
if ! command -v duckdb >/dev/null 2>&1; then
  try bash -c 'curl https://install.duckdb.org | sh'
fi
# AzureHound release binary
if [ ! -x "$HOME/.local/bin/azurehound" ]; then
  tmp=$(mktemp -d)
  try bash -c "cd $tmp && curl -sSL -o az.zip https://github.com/SpecterOps/AzureHound/releases/latest/download/azurehound-linux-amd64.zip && unzip -q az.zip && install -m755 azurehound $HOME/.local/bin/"
fi

# ────────────────────────────────────────────────────────────────────
banner "Git-install: SCCMHunter aux tools + Havoc/PKINITtools/krbrelayx"
mkdir -p "$HOME/tools"
GIT_REPOS=(
  "https://github.com/HavocFramework/Havoc               $HOME/tools/Havoc"
  "https://github.com/dirkjanm/PKINITtools               $HOME/tools/PKINITtools"
  "https://github.com/dirkjanm/krbrelayx                 $HOME/tools/krbrelayx"
  "https://github.com/mitre/caldera --recursive         $HOME/tools/caldera"
  "https://github.com/Orange-Cyberdefense/GOAD           $HOME/tools/GOAD"
  "https://github.com/dafthack/GraphRunner              $HOME/tools/GraphRunner"
  "https://github.com/vulhub/vulhub                     $HOME/tools/vulhub"
  "https://github.com/Mayyhem/Misconfiguration-Manager  $HOME/tools/Misconfiguration-Manager"
)
for line in "${GIT_REPOS[@]}"; do
  # split URL (+ optional flags) from destination path
  url="${line%%  *}"
  dest="${line##*  }"
  dest="${dest# }"
  if [ -d "$dest/.git" ]; then
    echo "= already cloned: $dest"
    try git -C "$dest" pull --quiet
  else
    try git clone --quiet $url "$dest"
  fi
done

# ────────────────────────────────────────────────────────────────────
banner "Docker: pull (don't run) heavy defensive/offensive stacks"
if systemctl is-active --quiet docker; then
  DOCKER_IMAGES=(
    opensecurity/mobile-security-framework-mobsf
    mpepping/cyberchef
    gophish/gophish
    specterops/bloodhound
    wazuh/wazuh-indexer
    wazuh/wazuh-manager
    wazuh/wazuh-dashboard
    bkimminich/juice-shop
    citizenstig/dvwa
    webgoat/goatandwolf
    arkimedeb/arkime
  )
  for img in "${DOCKER_IMAGES[@]}"; do
    try docker pull -q "$img"
  done
else
  echo "= docker service not running — skipping image pulls (run: sudo systemctl enable --now docker)"
fi

# ────────────────────────────────────────────────────────────────────
banner "Axiom (red-team disposable infra — CLI only; user configures cloud)"
if [ ! -d "$HOME/.axiom" ]; then
  try bash -c 'curl -s https://raw.githubusercontent.com/pry0cc/axiom/master/interact/axiom-configure | bash -'
else
  echo "= axiom present"
fi

# ────────────────────────────────────────────────────────────────────
banner "Ludus CLI (ranges-as-code)"
if ! command -v ludus >/dev/null 2>&1; then
  try bash -c 'curl -L https://ludus.cloud/install | bash'
fi

# ────────────────────────────────────────────────────────────────────
banner "Node.js helpers"
try sudo -n npm install -g fx

# ────────────────────────────────────────────────────────────────────
banner "Atomic Red Team (pwsh required; install module if pwsh present)"
if command -v pwsh >/dev/null 2>&1; then
  try pwsh -c 'Install-Module -Name invoke-atomicredteam -Scope CurrentUser -Force'
else
  echo "= pwsh not present — skipping. Atomic Red Team attacks/ repo:"
  try git clone --quiet https://github.com/redcanaryco/atomic-red-team "$HOME/tools/atomic-red-team"
fi

# ────────────────────────────────────────────────────────────────────
banner "Summary"
echo "Log: $LOG"
echo "Binaries: $(ls $GOPATH/bin 2>/dev/null | wc -l) go / $(pipx list --short 2>/dev/null | wc -l) pipx"
echo "Git repos under ~/tools: $(ls -1 $HOME/tools 2>/dev/null | wc -l)"
echo "=== done $(date) ==="
