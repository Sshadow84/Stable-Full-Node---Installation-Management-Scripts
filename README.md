<div align="center">

# ⚡ Stable Full Node Installer

### Automated Installation & Management Suite for Stable Testnet

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell_Script-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Stable Network](https://img.shields.io/badge/Network-Stable_Testnet-blue)](https://stable.xyz)

*Professional tooling for running Stable blockchain nodes with ease*

[Installation](#-quick-start) • [Features](#-features) • [Requirements](#-system-requirements) • [Documentation](#-usage-guide) • [Support](#-official-resources)

</div>

---

## 📖 About Stable Network

**Stable** is a next-generation decentralized computation network backed by top-tier investors including:

| Funding Round | Amount | Lead Investor | Date |
|--------------|--------|--------------|------|
| **Seed** | **$28M** | Hack VC | July 2025 |

**Notable Investors:** Bitfinex, KuCoin Ventures, and more

The project is currently in **public testnet phase**, allowing community participation through node operation.

---

## ⚙️ System Requirements

<table>
<tr>
<td width="50%">

### Minimum Specs
- **CPU:** 4 cores
- **RAM:** 8 GB
- **Storage:** 500 GB SSD
- **Network:** Stable internet
- **OS:** Ubuntu 20.04+ / Debian 11+

</td>
<td width="50%">

### Recommended Specs
- **CPU:** 8 cores
- **RAM:** 16 GB
- **Storage:** 1 TB NVMe SSD
- **Network:** 100+ Mbps
- **OS:** Ubuntu 22.04 LTS

</td>
</tr>
</table>

---

## ✨ Features

<div align="center">

| Feature | Description |
|---------|-------------|
| 🌍 **Bilingual Interface** | Full support for English & Russian |
| 🚀 **One-Command Install** | Automated setup with single command |
| 📸 **Snapshot Support** | Fast-sync with official snapshots |
| ⏰ **Automated Snapshots** | Scheduled updates via systemd timers |
| 🔄 **Version Management** | Easy binary upgrades & rollbacks |
| 💚 **Health Monitoring** | Built-in system health checks |
| 📊 **Resource Dashboard** | Real-time CPU, RAM, and disk usage |
| 🔧 **Peer Management** | Dynamic peer configuration |
| 🛡️ **Safe Operations** | Automatic backups before changes |

</div>

---

## 🚀 Quick Start

### Installation in 3 Steps

**Step 1:** Download and launch the installer

```bash
wget -q -O stable.sh https://raw.githubusercontent.com/Sshadow84/Stable-Full-Node---Installation-Management-Scripts/refs/heads/main/stable.sh && sudo chmod +x stable.sh && ./stable.sh
```

**Step 2:** Select your language, then choose:
- `1) Server Preparation` - Install dependencies
- `2) Node Installation` - Install Stable node
  - When asked `Apply snapshot now? [y/N]:` → Enter **y** for fast sync
- `3) Start node` - Launch the node service

**Step 3:** Verify node health (wait 10-15 minutes)
- `9) Health Check` - All indicators should be ✅ green

**Done!** Your node is now syncing with the Stable testnet 🎉

---

## 📋 Usage Guide

### Main Menu Options

```
┌─────────────────────────────────────────────┐
│  Stable Node — Installer & Manager         │
├─────────────────────────────────────────────┤
│  1)  Prepare server                         │
│  2)  Install node                           │
│  3)  Start node                             │
│  4)  Node logs (follow)                     │
│  5)  Node status                            │
│  6)  Restart node                           │
│  7)  Remove node                            │
│  8)  Node version                           │
│  9)  Health check                           │
│  10) Apply official snapshot                │
│  11) Snapshot automation (timer)            │
│  12) Update peers & restart                 │
│  13) Auto-upgrade binary                    │
│  14) Upgrade to specific version            │
│  15) Rollback to previous version           │
│  0)  Exit                                   │
└─────────────────────────────────────────────┘
```

### 🔍 Health Check Indicators

When you run **Health Check**, monitor these metrics:

| Indicator | Good | Warning |
|-----------|------|---------|
| Service Status | ✅ Running | ❌ Stopped |
| Sync Status | ✅ Synced | ⚠️ Syncing |
| Peer Count | ✅ 3+ peers | ⚠️ < 3 peers |
| Disk Usage | ✅ < 80% | ⚠️ > 80% |
| Memory Usage | ✅ < 80% | ⚠️ > 80% |

### 📊 Resource Monitoring

Launch the dashboard to view real-time resource usage:

```bash
bash stable_usage.sh
```

Displays:
- CPU utilization by core
- RAM usage (process + system)
- Disk space breakdown
- Network sync status
- Connected peers count

---

## 🔄 Snapshot Management

### Manual Snapshot Application

```
Menu → 10) Apply official snapshot
```

This will:
1. Stop the node service
2. Reset blockchain data (keeping address book)
3. Download latest official snapshot
4. Extract and apply snapshot
5. Restart node service

⏱️ **Estimated time:** 15-30 minutes depending on connection speed

### Automated Snapshots

```
Menu → 11) Snapshot automation (timer)
```

Options:
- **Install/Update timer** - Schedule daily snapshot updates
- **Disable timer** - Stop automated snapshots
- **Run snapshot now** - Manual trigger
- **Status** - View timer configuration

**Default schedule:** Daily at 00:15 (customizable)

---

## 🔧 Advanced Operations

### Peer Management

Keep your node well-connected:

```
Menu → 12) Update peers & restart
```

- Paste custom peer list, or
- Press Enter to use built-in backup peers (10 nodes)

### Version Upgrades

**Auto-detect from logs:**
```
Menu → 13) Auto-upgrade binary
```

**Manual version selection:**
```
Menu → 14) Upgrade to specific version
```

**Rollback if needed:**
```
Menu → 15) Rollback to previous version
```

All operations create automatic backups!

---

## 📦 Included Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `stable.sh` | Main installer & manager | `./stable.sh` |
| `stable_usage.sh` | Resource monitoring dashboard | `bash stable_usage.sh` |
| `stable-apply-snapshot.sh` | Snapshot automation helper | Called by systemd timer |

---

## 🛠️ Technical Details

### Network Configuration

- **Chain ID:** `stabletestnet_2201-1`
- **RPC Port:** 26657
- **Binary:** `stabled` v1.1.1
- **Service Name:** `stabled.service`
- **Data Directory:** `/root/.stabled`

### Data Sources

All critical components are fetched from **official Stable infrastructure**:

- **Binaries:** AWS S3 (us-east-1) - amd64/arm64 support
- **Genesis:** Official genesis.json with SHA256 verification
- **Configs:** Pre-configured config.toml & app.toml
- **Snapshots:** Official snapshot storage (eu-central-1)
- **Peers:** Curated list of reliable network nodes

---

## ❓ FAQ

<details>
<summary><b>How long does initial sync take?</b></summary>

- **With snapshot:** 20-40 minutes (recommended)
- **Without snapshot:** 6-24 hours depending on network
</details>

<details>
<summary><b>Can I run multiple nodes on one server?</b></summary>

Not with this script. Each installation uses the same paths and ports. Use separate VPS/containers for multiple nodes.
</details>

<details>
<summary><b>What if the node stops syncing?</b></summary>

1. Check peers: `Menu → 12) Update peers`
2. Check logs: `Menu → 4) Node logs`
3. Apply fresh snapshot: `Menu → 10) Apply snapshot`
</details>

<details>
<summary><b>How do I check if my node is working?</b></summary>

Run `Menu → 9) Health Check` - all indicators should be green ✅
</details>

<details>
<summary><b>Can I update the node version?</b></summary>

Yes! Use `Menu → 13` for auto-upgrade or `Menu → 14` for specific version.
</details>

---

## 🔐 Security Notes

- Script requires **root access** for system service management
- All downloads are from official Stable sources (AWS S3)
- Genesis file integrity verified via SHA256 checksum
- Automatic backups created before destructive operations
- No credentials or private keys are transmitted

---

## 🌐 Official Resources

<div align="center">

| Resource | Link |
|----------|------|
| 🏠 **Website** | [stable.xyz](https://www.stable.xyz/) |
| 🐦 **Twitter** | [@stable](https://x.com/stable) |
| 💬 **Discord** | [Join Community](https://discord.com/invite/stablexyz) |
| 📢 **Announcement** | [Official Tweet](https://x.com/stable/status/1985715183206236368) |

</div>

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

This is a community-maintained installation tool for the Stable testnet. Node operation does not guarantee any rewards or benefits. Always verify you're using official Stable Network resources and exercise caution when running blockchain infrastructure.

---

<div align="center">

### 🌟 Happy Node Running! 🌟

*If you find this tool helpful, consider giving it a ⭐ on GitHub*

**Made with ❤️ for the Stable community**

</div>
