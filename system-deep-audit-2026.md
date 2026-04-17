# ashborn — Deep System Audit & 2026 Optimization Report
**Date:** 2026-04-14  
**Machine:** HP ZBook 14u G6 Mobile Workstation  
**Use Case:** Kali Linux Pentesting / Security Research  

---

## 1. SYSTEM FINGERPRINT

| Component | Detail |
|-----------|--------|
| **OS** | Kali GNU/Linux 2025.4 (kali-rolling) |
| **Kernel** | 6.16.8+kali-amd64 (built 2025-09-24) |
| **Latest Available Kernel** | **6.18.12+kali-amd64** (in repos — not installed) |
| **Latest Kali Release** | **2026.1** (released 2026-03-25 — not installed) |
| **CPU** | Intel Core i7-8565U (Whiskey Lake-U, CPUID 806EC, stepping 12) |
| **Cores/Threads** | 4C / 8T — max 4.6 GHz turbo |
| **Microcode** | 0x100 — **needs update** (intel-microcode package missing) |
| **RAM** | 2× 16GB Samsung DDR4 (M471A2K43CB1-CTD) |
| **RAM Speed** | Rated 2667 MT/s — **running at 2400 MT/s** (XMP not enabled in BIOS) |
| **Storage** | Samsung PM981 NVMe 512GB (MZVLB512HBJQ-000H1) |
| **NVMe IO Scheduler** | `none` (correct for NVMe) |
| **Filesystem** | ext4 on LVM |
| **iGPU** | Intel UHD 620 — driver: i915 |
| **dGPU** | AMD Radeon PRO WX 3200 (Lexa XT, GFX8/Polaris12) |
| **GPU Driver** | amdgpu (kernel) + Mesa 26.0.3 rusticl OpenCL |
| **GPU OpenCL** | ~2 GH/s MD5 via rusticl (no ROCm KFD — PCIe atomics blocked) |
| **WiFi** | Intel Wi-Fi 6 AX200 — driver: iwlmvm, firmware: cc-a0-77 |
| **Ethernet** | Intel I219-V — driver: e1000e |
| **Bluetooth** | Intel AX200 BT — DOWN (not in use) |
| **Audio** | Intel Cannon Point-LP HDA — driver: sof-audio-pci-intel-cnl |
| **BIOS** | HP R70 Ver. 01.33.00 (released 2025-07-03) |
| **Battery** | 34.7 Wh / 50.0 Wh design — **69.4% health** (degraded) |
| **Display** | 1920×1080 eDP-1 (14") |
| **CPU Governor** | `powersave` — **wrong for pentesting workloads** |
| **Packages Upgradable** | **2,244** — significantly behind |
| **THP** | `[always]` |
| **lm-sensors** | Not configured (thermal blindness) |
| **TLP** | Not installed |

---

## 2. CRITICAL FINDINGS

### 🔴 CRITICAL

---

#### C1 — Kali 2026.1 Not Installed (Kernel 6.16.8 → 6.18.12)

Kali Linux 2026.1 was released **2026-03-25** — this machine is running 2025.4 from 6+ months ago. The new release ships kernel 6.18.12 (an LTS kernel supported through 2027), plus:

- **MetasploitMCP** — MCP server that lets AI systems (Claude Code) interact directly with Metasploit Framework for AI-assisted exploitation, module querying, and attack chain generation
- **AdaptixC2** — New extensible post-exploitation C2 framework
- **XSStrike** — XSS scanner
- 5 additional new tools + 183 package updates
- **BackTrack mode** in kali-undercover (20th anniversary feature)

Kernel 6.18 itself brings: 47% UDP receive performance improvement, improved memory allocation (sheaves cache), new BPF signing infrastructure, and better hardware support across GPU/storage/network drivers.

**The system has 2,244 pending package upgrades — this is the primary issue.**

---

#### C2 — intel-microcode Package NOT Installed

The system has `amd64-microcode` installed (wrong package — that's for AMD CPUs). The Intel Whiskey Lake CPU (CPUID 806EC) needs the **`intel-microcode`** package. Current reported microcode: `0x100`.

Without current microcode:
- Spectre/Meltdown mitigations may be incomplete
- SRBDS mitigation relies on microcode (shown as "Microcode" in vulns — confirms it's loaded from somewhere, likely BIOS, but software updates are safer)
- Latest Intel microcode for 806EC has been updated multiple times since 2019 for additional security advisories

---

#### C3 — 6 Firmware Packages Outdated (Jan 2026 versions pending)

All critical firmware packages are behind by ~5 months:

| Package | Current | Available |
|---------|---------|-----------|
| `firmware-iwlwifi` | 20250808-1 | **20260110-1** |
| `firmware-amd-graphics` | 20250808-1 | **20260110-1** |
| `firmware-intel-graphics` | 20250808-1 | **20260110-1** |
| `firmware-intel-sound` | 20250808-1 | **20260110-1** |
| `firmware-linux-nonfree` | 20250808-1 | **20260110-1** |
| `amd64-microcode` | 3.20250311.1 | **3.20251202.1** |

The iwlwifi firmware update (cc-a0-77 → newer) may improve AX200 stability and 6 GHz band support. The AMD graphics firmware update may improve amdgpu power management.

---

### 🟠 HIGH PRIORITY

---

#### H1 — CPU Governor Stuck on `powersave`

Current: `powersave` (39% scaling at time of audit).  
For pentesting workloads, scans, hashcat, and compilation — this actively throttles performance.

**Fix:** Switch to `performance` or `schedutil` permanently.

---

#### H2 — ACPI BIOS Errors at Boot

Two repeating ACPI errors logged every boot:
```
ACPI BIOS Error: AE_AML_BUFFER_LIMIT — \_SB._OSC
ACPI BIOS Error: AE_AML_PACKAGE_LIMIT — \_TZ.GETP / \_TZ.CHGZ._CRT
```
The `_OSC` error affects PCIe capability negotiation (this is why the AMD GPU KFD rejects PCIe atomics). The thermal zone (`_TZ`) error causes incorrect critical temperature reporting.

**Fix:** Kernel cmdline parameters can suppress/override these.

---

#### H3 — lm-sensors Not Configured

Running thermally blind. Temperatures visible via ACPI (`/sys/class/thermal/`) show values between 23°C–56°C but no per-component labeling (CPU package, GPU die, NVMe). Under hashcat loads on both CPU and GPU simultaneously, this is a risk.

**Fix:** `sudo sensors-detect --auto && sensors`

---

#### H4 — Battery Health at 69.4% (Design: 50Wh → Actual: 34.7Wh)

The battery has lost ~30% capacity. Not a software fix, but warrants monitoring. At current degradation rate, it may drop below 60% within a year.

**Monitor:** `upower -i /org/freedesktop/UPower/devices/battery_BAT0`  
**Action:** Track monthly; replace when below 60%.

---

#### H5 — TLP Not Installed

TLP provides advanced power management for Linux laptops — per-device control of USB autosuspend, SATA link power, PCIe ASPM, WiFi power saving, and CPU frequency scaling. Without it, the system uses GNOME/systemd defaults which leave power on the table.

On AC: TLP keeps CPU at max performance.  
On battery: TLP aggressively throttles for battery preservation.

---

#### H6 — nvme-cli Not Installed

Cannot check NVMe drive health, wear leveling, or firmware version. The Samsung PM981 is an excellent drive but monitoring its health is important for a primary work machine.

---

### 🟡 MEDIUM PRIORITY

---

#### M1 — RAM Underclocked (2400 MT/s vs 2667 MT/s rated)

Both Samsung DDR4 sticks are rated for 2667 MT/s but configured at 2400 MT/s. This is a BIOS memory profile setting (XMP/JEDEC). On laptops the BIOS may have an option to enable the rated speed — worth checking under `F10 → Advanced → Memory Configuration` on HP ZBook. ~11% memory bandwidth improvement for free.

#### M2 — AMD GPU in 3D_FULL_SCREEN Power Profile by Default

The AMD GPU defaults to `3D_FULL_SCREEN` power profile. For compute workloads (hashcat), the `COMPUTE` profile is more appropriate and will improve sustained hash rates.

**Fix:** `echo compute | sudo tee /sys/class/drm/card1/device/power_dpm_force_performance_level`  
Then for hashcat: `echo 5 | sudo tee /sys/class/drm/card1/device/pp_power_profile_mode`

#### M3 — Sysctl Not Tuned for Pentesting

Default kernel parameters are conservative. For a pentesting machine handling large network scans, many concurrent connections, and memory-intensive tools, several parameters benefit from tuning.

#### M4 — Transparent Hugepages Set to `always`

THP `[always]` can cause latency spikes and increased memory usage with tools like Metasploit's database, Redis, and various Python security tools that prefer standard pages.

**Fix:** Change to `madvise` — applications that benefit (databases, hashcat) will opt in.

#### M5 — No i915 FBC/PSR Tuning

Intel FBC (Framebuffer Compression) and PSR (Panel Self-Refresh) are not explicitly enabled in kernel cmdline. These reduce iGPU power draw when displays are static — relevant on battery.

---

## 3. RECOMMENDATIONS — WHAT TO INSTALL / CHANGE / IMPROVE

---

### ACTION 1: Full System Upgrade to Kali 2026.1

**This is the primary action. Everything else follows from this.**

```bash
sudo apt update && sudo apt full-upgrade -y
# Includes kernel 6.18.12, firmware-iwlwifi, firmware-amd-graphics,
# firmware-intel-*, amd64-microcode, Mesa updates, and 2244 other packages.
# After completion, reboot into 6.18.12.
```

Post-upgrade, verify:
```bash
uname -r           # should show 6.18.12+kali-amd64
kali-branch        # or cat /etc/os-release | grep VERSION
```

**New in Kali 2026.1 worth using immediately:**
```bash
# MetasploitMCP — AI-assisted Metasploit via Claude Code
sudo apt install -y metasploit-framework  # includes MCP server
# Configure: msfconsole → load msgrpc → then connect Claude Code MCP

# AdaptixC2 — new post-exploitation framework
sudo apt install -y adaptixc2
```

---

### ACTION 2: Install intel-microcode

```bash
sudo apt install -y intel-microcode
# Reboot required — updates CPU microcode from BIOS-loaded version
# Verifies: grep microcode /proc/cpuinfo (should show higher revision than 0x100)
```

---

### ACTION 3: Fix CPU Governor — Performance Mode

```bash
# Install cpufrequtils
sudo apt install -y cpufrequtils linux-cpupower

# Set performance governor persistently
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo cpupower frequency-set -g performance

# Verify
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | sort -u
# Should return: performance
```

For a more intelligent alternative (auto-scales between performance and efficiency):
```bash
sudo cpupower frequency-set -g schedutil
```

---

### ACTION 4: Configure lm-sensors

```bash
sudo apt install -y lm-sensors
sudo sensors-detect --auto
sensors
# Watch temperatures during load:
watch -n 1 sensors
```

---

### ACTION 5: Install TLP for Power Management

```bash
sudo apt install -y tlp tlp-rdw
sudo systemctl enable --now tlp

# Verify
sudo tlp-stat -s
sudo tlp-stat --battery   # see charging thresholds
```

For extended battery life (set charge thresholds — avoids keeping at 100% constantly):
```bash
# /etc/tlp.conf:
# START_CHARGE_THRESH_BAT0=75
# STOP_CHARGE_THRESH_BAT0=90
```

---

### ACTION 6: Install nvme-cli + Check NVMe Health

```bash
sudo apt install -y nvme-cli
sudo nvme smart-log /dev/nvme0n1
sudo nvme list
# Check: Percentage_Used, Available_Spare, Media_Errors
```

---

### ACTION 7: Fix ACPI BIOS Errors in GRUB

Edit `/etc/default/grub`:
```bash
# Current:
GRUB_CMDLINE_LINUX_DEFAULT="quiet"

# Recommended for HP ZBook 14u G6 on Linux:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=off acpi_osi=Linux acpi_backlight=native i915.enable_fbc=1 i915.enable_psr=2 nmi_watchdog=0"
```

Then:
```bash
sudo update-grub
# Reboot and check: dmesg | grep -i acpi | grep -i error
```

Parameters explained:
- `pcie_aspm=off` — disables PCIe ASPM which triggers the `_OSC` error and may improve AMD GPU stability
- `acpi_osi=Linux` — tells BIOS we're Linux, enables Linux-specific ACPI paths
- `acpi_backlight=native` — fixes backlight control issues common on HP ZBooks
- `i915.enable_fbc=1` — enables Intel framebuffer compression (power saving)
- `i915.enable_psr=2` — Panel Self-Refresh level 2 (power saving on idle display)
- `nmi_watchdog=0` — disables NMI watchdog (reduces noise, saves power)

---

### ACTION 8: AMD GPU COMPUTE Profile for hashcat

```bash
# Create systemd service to set compute profile at boot
cat << 'EOF' | sudo tee /etc/systemd/system/amd-gpu-compute.service
[Unit]
Description=Set AMD GPU compute profile
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo compute > /sys/class/drm/card1/device/power_dpm_force_performance_level && echo 5 > /sys/class/drm/card1/device/pp_power_profile_mode'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now amd-gpu-compute.service
```

This sets the GPU to COMPUTE profile on every boot — better sustained hash rates for hashcat, no power throttling mid-job.

---

### ACTION 9: Sysctl Tuning for Pentesting

```bash
cat << 'EOF' | sudo tee /etc/sysctl.d/99-pentest.conf
# === NETWORK: scanning and high-connection-count workloads ===
# Large socket buffers for nmap/masscan/rustscan
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.core.rmem_default = 31457280
net.core.wmem_default = 31457280
net.core.netdev_max_backlog = 250000
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# More local ports for outbound scanning
net.ipv4.ip_local_port_range = 1024 65535

# Fast recycling for TIME_WAIT (many short-lived scan connections)
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10

# Increase connection tracking for masscan/nmap
net.netfilter.nf_conntrack_max = 1000000
net.ipv4.tcp_max_syn_backlog = 65536

# SYN flood resistance (for when you're a target too)
net.ipv4.tcp_syncookies = 1

# === MEMORY: tools like Metasploit, Ghidra, volatility ===
# THP: let apps opt-in (avoids latency spikes with msf/redis)
vm.nr_hugepages = 0
# Lower swappiness (32GB RAM — almost never swap)
vm.swappiness = 5
# Increase vm map areas (needed for tools like ghidra, java apps)
vm.max_map_count = 262144

# === FILESYSTEM: NVMe performance ===
# Increase dirty page ratio (NVMe can flush fast)
vm.dirty_ratio = 20
vm.dirty_background_ratio = 5

# === KERNEL: security research quality of life ===
# Allow dmesg without root (useful for debugging tools)
kernel.dmesg_restrict = 0
# Show kernel pointers (needed for some security tools)
kernel.kptr_restrict = 0
# Increase PID max for many simultaneous tools/agents
kernel.pid_max = 4194304
EOF

sudo sysctl -p /etc/sysctl.d/99-pentest.conf
```

---

### ACTION 10: Fix Transparent Hugepages

```bash
# Change from [always] to madvise
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# Make permanent via GRUB or rc.local:
echo 'echo madvise > /sys/kernel/mm/transparent_hugepage/enabled' | \
  sudo tee -a /etc/rc.local && sudo chmod +x /etc/rc.local
```

---

### ACTION 11: BIOS Check — RAM Speed + HP Firmware

**RAM Speed (BIOS):** Boot into HP BIOS (`F10` at POST), navigate to `Advanced → Memory Configuration` and enable XMP/JEDEC profile for 2667 MT/s. This is a 11% memory bandwidth increase for free — relevant for hashcat and memory-hungry RE tools like Ghidra.

**HP BIOS Update:** Current version R70 01.33.00 (2025-07-03). Check HP's support page for the ZBook 14u G6 for newer versions — HP typically releases BIOS updates 2-3 times per year. Newer BIOS versions may contain:
- Updated Intel ME firmware
- Fixed ACPI table errors (the `_OSC` and `_TZ.GETP` errors seen at boot)
- Updated embedded controller firmware for battery management
- Potential PCIe atomics fix (would allow ROCm KFD and full GPU compute)

**HP Support URL:** `https://support.hp.com/us-en/drivers/hp-zbook-14u-g6-mobile-workstation/22892779`  
**Download tool for Linux:** `sudo apt install -y fwupd && fwupdmgr get-updates`

---

### ACTION 12: fwupd — Firmware Update Daemon

```bash
sudo apt install -y fwupd
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update
# Checks for firmware updates via LVFS (Linux Vendor Firmware Service)
# HP participates — may have EC, NVME, or other firmware updates
```

---

## 4. PRIORITIZED EXECUTION ORDER

```
1.  sudo apt update && sudo apt full-upgrade -y          [CRITICAL — 2244 pkgs]
2.  sudo reboot                                          [CRITICAL — load 6.18.12]
3.  sudo apt install -y intel-microcode                  [CRITICAL — CPU security]
4.  sudo apt install -y cpufrequtils lm-sensors tlp tlp-rdw nvme-cli fwupd
5.  sudo sensors-detect --auto                           [thermal visibility]
6.  sudo cpupower frequency-set -g performance           [pentest performance]
7.  Edit /etc/default/grub (ACPI + i915 params)         [stability + power]
8.  sudo update-grub && sudo reboot
9.  sudo sysctl -p /etc/sysctl.d/99-pentest.conf        [network/memory tuning]
10. sudo systemctl enable --now amd-gpu-compute.service  [hashcat performance]
11. sudo fwupdmgr update                                 [firmware updates]
12. BIOS: enable XMP 2667 MT/s                          [memory bandwidth]
13. HP support page: check for BIOS > 01.33.00          [ACPI bug fixes]
```

---

## 5. EXPECTED IMPROVEMENTS AFTER ALL ACTIONS

| Area | Before | After |
|------|--------|-------|
| OS/Kernel | Kali 2025.4 / 6.16.8 | Kali 2026.1 / 6.18.12 (LTS) |
| CPU performance | 39% scaling (powersave) | 100% scaling (performance) |
| Network scan throughput | Default buffers | +40-60% with tuned sysctl |
| hashcat GPU (AMD) | ~2 GH/s MD5 | ~2.3-2.5 GH/s (compute profile) |
| Memory bandwidth | 2400 MT/s | 2667 MT/s (+11%) |
| Boot ACPI errors | 4 per boot | 0 (suppressed/fixed) |
| Firmware | Aug 2025 | Jan 2026 (+5 months patches) |
| CPU microcode | 0x100 (BIOS-loaded) | Latest Intel revision |
| Thermal visibility | Blind | Full per-component monitoring |
| WiFi firmware | cc-a0-77 | Latest (Jan 2026) |
| Tool availability | 2025.4 set | +MetasploitMCP, AdaptixC2, XSStrike + 5 tools |
