# Kali Enhancement Project

A systematic audit + buildout of a Kali Linux workstation for defensive security
research, homelab work, and detection engineering.

Started from a stock `kali-linux-default` install and iterated through a
structured plan:

1. **Audit** — full inventory of hardware, kernel, network stack, installed
   packages, and the delta vs. the security-tooling baseline I wanted.
2. **Research** — survey of 2026-era tooling across recon, AD, DFIR, malware
   analysis, threat hunting, and cloud posture.
3. **Enhancement plan** — prioritized tier list of what to install and why.
4. **Installation** — reproducible install scripts (`scripts/`) with logging.
5. **Verification** — `verify-tools.sh` to sanity-check the final state.
6. **Documentation** — quick-reference guide for daily operator use.

## Layout

| Path | Purpose |
|---|---|
| `01-system-audit-report.md` | Baseline audit of the host before any changes |
| `02-pentesting-research.md` | 2026 tooling survey with adoption notes |
| `03-enhancement-plan.md` | Prioritized install plan (tier 1 → tier 2) |
| `04-installation-log.md` | What got installed, when, with what flags |
| `05-testing-results.md` | Verification pass/fail per tool |
| `06-final-tool-inventory.md` | End-state inventory |
| `07-quick-reference-guide.md` | Day-to-day command cheatsheet |
| `scripts/verify-tools.sh` | Health check across the full toolset |
| `scripts/install-tier1-tools.sh` | Baseline recon / web / exploitation tools |
| `scripts/install-tier2-2026.sh` | 2026-tier tooling (Sliver, Havoc, GOAD, etc.) |
| `scripts/update-all-tools.sh` | Rolling-update sweep across package managers |
| `gap-audit-20260415.md` | Follow-up gap analysis after tier-2 install |
| `deep-audit-execution-summary.md` | Deep-dive audit run |
| `system-deep-audit-2026.md` | Full deep audit report |
| `audit-20260415-0024.md` | Incremental audit snapshot |
| `raw-data/installed-packages.txt` | Debian package inventory |

## Scope

This repository is for lab and defensive research use. The install scripts
pull categories like recon, AD analysis, DFIR, threat hunting, and malware
analysis tooling. Use in authorized environments only.

## Reproducing

```bash
git clone https://github.com/oblivionlabz/kali-enhancement-project
cd kali-enhancement-project
# Read 03-enhancement-plan.md first — understand what you're about to install
bash scripts/install-tier1-tools.sh
bash scripts/install-tier2-2026.sh
bash scripts/verify-tools.sh
```

## License

MIT — see [`LICENSE`](LICENSE).
