# 📋 Detailed Menu Description for Stable Node Manager

## Main Menu

---

### 1) 📦 Initialize Server Environment

**What it does:**
- Updates APT package list (`apt update`)
- Upgrades all installed packages to latest versions (`apt upgrade -y`)
- Installs required dependencies:
  - `curl` - for downloading files via HTTP/HTTPS
  - `wget` - alternative download tool
  - `tar` - for unpacking archives
  - `unzip` - for working with ZIP archives
  - `jq` - for JSON parsing (used in RPC checks)
  - `lz4` - for unpacking snapshots (compression format)
  - `pv` - for displaying unpacking progress

**Purpose:**
This is the first mandatory step before node installation. Prepares a clean server by installing all necessary tools for Stable node operation. Without these packages, node installation will be impossible.

**When to use:**
- On a new server before first installation
- After OS reinstallation
- If any dependencies are missing

---

### 2) ⚙️ Deploy Stable Node

**What it does:**

1. **Architecture Detection:**
   - Automatically detects CPU architecture (amd64 or arm64)
   - Selects appropriate binary file for download

2. **Node Name Request (Moniker):**
   - Asks for a UNIQUE name for your node (mandatory, Latin characters only)
   - Validates input: only Latin letters, numbers, dash (-) and underscore (_)
   - This name will be displayed on the network
   - **⚠️ Use ONLY Latin characters (ASCII)!**

3. **Binary Download:**
   - Downloads official `stabled` binary v1.1.1 from AWS S3
   - Unpacks and installs to `/usr/bin/stabled`
   - Makes file executable

4. **Node Initialization:**
   - Executes `stabled init` with your name and chain-id `stabletestnet_2201-1`
   - Creates directory structure in `/root/.stabled`

5. **Genesis File Download:**
   - Downloads official genesis.json from AWS S3
   - Verifies SHA256 checksum for security
   - Expected hash: `66afbb6e57e6faf019b3021de299125cddab61d433f28894db751252f5b8eaf2`

6. **Configuration Setup:**
   - Downloads pre-configured config.toml and app.toml
   - Applies your moniker to config
   - Configures CORS (`cors_allowed_origins = ["*"]`)
   - Adds list of verified peers
   - Sets connection limits:
     - Inbound: 50 peers
     - Outbound: 30 peers
   - Enables RPC on ports:
     - JSON-RPC: 8545
     - WebSocket: 8546

7. **Systemd Service Creation:**
   - Creates `/etc/systemd/system/stabled.service` file
   - Configures auto-restart on failure (RestartSec=3)
   - Sets open file limit (65535)
   - Enables service autostart

8. **Optional Snapshot Application:**
   - Asks: "Apply snapshot now? [y/N]:"
   - If you choose `y`:
     - Creates backup of current data
     - Downloads official snapshot (~several GB)
     - Unpacks blockchain data
     - This speeds up sync from 6-24 hours to 20-40 minutes

**Purpose:**
Complete automatic installation and configuration of Stable node from A to Z. After this step, the node will be ready to start.

**When to use:**
- First node installation on server
- After complete removal of previous installation
- Once per server

---

### 3) 🚀 Start Node Service

**What it does:**
- Executes command `systemctl start stabled`
- Starts node service in background
- Node begins connecting to peers and synchronizing

**Purpose:**
Starts the node after installation or after stopping. After start, node begins work: connects to Stable network, downloads blocks, validates transactions.

**When to use:**
- Right after installation (step 2)
- After stopping the node
- After server reboot (though service is configured for autostart)

---

### 4) 📜 View Event Log

**What it does:**
- Executes `journalctl -u stabled -f -n 200`
- Shows last 200 lines of logs
- Flag `-f` means "follow" mode - logs update in real-time
- Shows all events: peer connections, block sync, errors

**Purpose:**
Real-time monitoring of node operation. Here you'll see:
- Block synchronization process
- Number of connected peers
- Errors and warnings
- Current block height
- Version update messages

**When to use:**
- To check node is working normally
- When diagnosing problems
- To track synchronization progress
- Press `Ctrl+C` to exit log viewing mode

---

### 5) 📊 Node Operation Info

**What it does:**
- Executes `systemctl status stabled`
- Shows brief service status information:
  - Status: active (running) / inactive / failed
  - Start time and uptime
  - Process PID
  - Memory usage
  - Last log lines

**Purpose:**
Quick status check without detailed logs. Allows confirming node is running.

**When to use:**
- For quick status check
- To know how long node has been running
- To check if service hasn't crashed

---

### 6) 🔄 Restart Service

**What it does:**
- Executes `systemctl restart stabled`
- Stops the node
- Immediately starts it again
- All peer connections are reestablished

**Purpose:**
Node restart to apply changes or solve problems. After restart, node:
- Rereads configuration files
- Clears memory
- Reconnects to peers

**When to use:**
- After configuration changes (config.toml, app.toml)
- With peer connection problems
- If node "hangs" or works unstably
- After updating peer list

---

### 7) 🗑️ Complete Node Removal

**What it does:**

1. **Requests Confirmation:**
   - "Remove binary, service and all node data? [y/N]:"
   - Requires explicit consent

2. **Stops All Services:**
   - Stops `stabled.service`
   - Disables service autostart
   - Stops auto-snapshot timers

3. **Removes Systemd Files:**
   - `/etc/systemd/system/stabled.service`
   - `/etc/systemd/system/stable-snapshot.service`
   - `/etc/systemd/system/stable-snapshot.timer`
   - Reloads systemd daemon

4. **Terminates Processes:**
   - Soft termination of stabled process
   - After one second forced termination (kill -9)

5. **Removes Locks:**
   - Deletes LOCK files from database
   - Frees files for possible reuse

6. **Deletes All Data:**
   - Node directory: `/root/.stabled` (all blocks, states, configs)
   - Backups: `/root/stable-backup`
   - Snapshots: `/root/snapshot`
   - Temp files: `/tmp/stable_genesis`, `/tmp/rpc_cfg`
   - Binary: `/usr/bin/stabled`
   - Logs: `/var/log/stabled`

**Purpose:**
Complete node removal from server with all data. Returns server to "before installation" state.

**When to use:**
- Before clean node reinstallation
- When decommissioning node
- To free disk space
- **WARNING:** This is irreversible! All blockchain data will be deleted.

---

### 8) 🏷️ Show Binary Version

**What it does:**
- Executes `stabled version` command
- Shows installed binary version
- Usually displays: `1.1.1` or other current version

**Purpose:**
Check current node version. Useful for:
- Determining if update is needed
- Confirming successful update
- Diagnosing compatibility issues

**When to use:**
- Before updating (to know current version)
- After updating (for verification)
- When seeing outdated version messages in logs

---

### 9) 💚 Health Check

**What it does:**

Comprehensive node health check across 5 parameters:

1. **Service Status:**
   - Checks: `systemctl is-active stabled`
   - ✅ Green: Service running
   - ❌ Red: Service stopped (shows logs for diagnostics)

2. **Sync Status:**
   - RPC request: `curl localhost:26657/status`
   - Checks `catching_up` field:
     - ✅ Green: `false` - node synchronized
     - ⚠️ Yellow: `true` - synchronizing

3. **Peer Count:**
   - RPC request: `curl localhost:26657/net_info`
   - Checks `n_peers`:
     - ✅ Green: 3+ connected peers (good)
     - ⚠️ Yellow: < 3 peers (poor connectivity)

4. **Disk Usage:**
   - Command: `df -h /`
   - Checks percentage of used space:
     - ✅ Green: < 80% (enough space)
     - ⚠️ Yellow: ≥ 80% (need to free space)

5. **Memory Usage:**
   - Command: `free -m`
   - Calculates RAM usage percentage:
     - ✅ Green: < 80% (enough memory)
     - ⚠️ Yellow: ≥ 80% (high memory load)

**Purpose:**
Quick node health diagnostics "at a glance". Shows all critical parameters in convenient format.

**When to use:**
- 10-15 minutes after starting node (to check successful installation)
- Daily for monitoring
- When suspecting problems
- Before applying snapshot (to understand if it's needed)

---

### 10) 📸 Quick Sync (snapshot)

**What it does:**

1. **Requests Confirmation:**
   - "DB will be reset and official snapshot applied. Continue? [y/N]:"

2. **Stops Node:**
   - `systemctl stop stabled`

3. **Data Reset (preserving address book):**
   - Executes: `stabled comet unsafe-reset-all --keep-addr-book`
   - Deletes all blocks, states, transactions
   - **Preserves** list of known peers (addrbook.json)

4. **Snapshot Download:**
   - URL: `https://stable-snapshot.s3.eu-central-1.amazonaws.com/snapshot.tar.lz4`
   - Size: several gigabytes (depends on snapshot age)
   - Shows download progress

5. **Old Data Removal:**
   - Completely clears `/root/.stabled/data`

6. **Snapshot Unpacking:**
   - Uses `pv` to display progress
   - Unpacks using lz4
   - Extracts to `/root/.stabled/`

7. **Node Restart:**
   - `systemctl start stabled`
   - Waits 10 seconds
   - Checks sync status and block height

**Purpose:**
Quick node synchronization to current network state. Instead of downloading all blocks from scratch (6-24 hours), you get ready state (20-40 minutes).

**When to use:**
- On first installation (if didn't apply snapshot in step 2)
- If node is far behind network (catching_up long `true`)
- After long node downtime
- With synchronization problems
- To save time and traffic

**Estimated time:** 15-30 minutes depending on internet speed

---

### 11) ⏰ Auto-sync Scheduler

**What it does:**

Submenu for managing automatic snapshot application:

#### 1) ⏰ Install/Update daily timer
**What it does:**
- Downloads helper script `stable-apply-snapshot.sh` (if missing)
- Requests time for daily run (default: 00:15)
- Creates systemd service: `/etc/systemd/system/stable-snapshot.service`
- Creates systemd timer: `/etc/systemd/system/stable-snapshot.timer`
- Configures `OnCalendar` to specified time
- Enables and starts timer
- Adds random delay up to 5 minutes (`RandomizedDelaySec=300`)

**Purpose:** Automate daily node updates via snapshot. Ensures your node is always current.

#### 2) ⛔ Disable timer
**What it does:**
- Stops timer
- Disables timer autostart
- Doesn't delete files, just deactivates

**Purpose:** Temporarily or permanently disable automatic snapshots.

#### 3) ▶️ Run snapshot now (oneshot)
**What it does:**
- Immediately starts `stable-snapshot.service`
- Performs same actions as main menu item 10
- Doesn't wait for timer schedule

**Purpose:** Manual snapshot trigger via automated service.

#### 4) 📊 Status
**What it does:**
- Shows timer status: `systemctl status stable-snapshot.timer`
- Shows service status: `systemctl status stable-snapshot.service`
- Displays next run schedule: `systemctl list-timers`
- Shows logs of recent executions

**Purpose:** Check automation operation, view execution history.

#### 5) 🔄 Fetch/Update helper from GitHub
**What it does:**
- Downloads latest `stable-apply-snapshot.sh` version from GitHub
- Saves to `/usr/local/bin/stable-apply-snapshot.sh`
- Makes file executable

**Purpose:** Update auto-snapshot script when fixes or improvements are available.

**When to use menu 11:**
- Set up timer once after node installation
- Check status periodically
- Update helper when new versions appear

---

### 12) 🌐 Update Peer List

**What it does:**

1. **Shows Current Peers:**
   - Reads `persistent_peers` from config.toml
   - Displays list of current connections

2. **Requests New Peers:**
   - You can paste your peer list (format: `nodeID@ip:port,nodeID@ip:port`)
   - Or press Enter - then backup peers are used (10 nodes)

3. **Creates Config Backup:**
   - Copies config.toml with timestamp
   - Example: `config.toml.bak.2025-11-19_14-30-45`

4. **Writes New Configuration:**
   - Removes old peer settings from [p2p] section
   - Adds new settings:
     - `seeds = ""`
     - `persistent_peers = "your_peer_list"`
     - `persistent_peers_max_dial_period = "0s"`
     - `pex = true` (enables peer address exchange)
     - `addr_book_strict = false` (less strict address checking)

5. **Restarts Node:**
   - `systemctl restart stabled`
   - Waits 3 seconds

6. **Checks Result:**
   - Requests connected peer count via RPC
   - Checks sync status
   - Displays results

**Purpose:**
Improve node network connectivity. If you have few peers or connection problems, updating peer list solves the issue.

**When to use:**
- With low peer count (< 3)
- If node isn't synchronizing
- With network connection problems
- When old peers don't respond
- Periodically to update active node list

**Backup peers (used by default):**
```
e8dc4eb1aed53078d90209c7d8d19d10e79e40bb@62.84.184.22:26656
babe0a3c95868b13cafe31d3473ab646268b7ceb@217.76.62.42:26656
9b9897064ed6a27f3e44d3269ebe9bc06e1ba233@217.76.55.225:26656
91947248cd012523a7b8cfe40791e09465031396@38.242.158.172:26656
86dab3dc399c33ff9770fd089f51125d004a2fe3@130.185.118.7:26656
0bbbed1c8c054f66d45e81a11520456f42e7fca7@45.8.132.10:26656
68a099f9fcf3a3fcff6e549105d206125b51d973@62.169.31.251:26656
0a09e1e1c96f3e8be3204bf10d35ac64294ca826@109.199.108.76:26656
5db9f874c394590ce45c7d946fbd1a1afbf01d21@5.189.136.244:26656
d941c5214bd00b2652a638397c1121fa4a51eae4@89.117.58.6:26656
```

---

### 13) 🤖 Auto-detect Upgrades

**What it does:**

1. **Scans Logs:**
   - Executes: `journalctl -u stabled -n 2000`
   - Searches logs for messages like: `Upgrade to v1.2.0`
   - Extracts version number

2. **Determines Upgrade Version:**
   - If version found in logs - uses it
   - If not found - asks manually (default: 1.1.1)

3. **Performs Upgrade:**
   - Stops node: `systemctl stop stabled`
   - Creates timestamped backup of current binary
   - Determines architecture (amd64/arm64)
   - Downloads new binary from AWS S3
   - URL: `https://stable-testnet-data.s3.us-east-1.amazonaws.com/stabled-{VERSION}-linux-{ARCH}-testnet.tar.gz`
   - Unpacks archive
   - Replaces old binary with new one
   - Makes file executable
   - Starts node: `systemctl start stabled`
   - Checks new version and status

**Purpose:**
Automatic update to network-required version. When network transitions to new version, upgrade message appears in logs. This option simplifies the process.

**When to use:**
- When seeing messages like "Upgrade to v1.x.x" in logs
- Upon update recommendation from Stable team
- When node can't sync due to outdated version

**Advantages:**
- Automatic detection of needed version
- Backup created for rollback possibility
- Minimal manual actions

---

### 14) ⬆️ Install Target Version

**What it does:**

Same as step 13, but **without version auto-detection**.

1. **Requests Version:**
   - You enter specific version (e.g., `1.2.0`)

2. **Performs Upgrade:**
   - All steps identical to step 13
   - Stops node
   - Creates backup
   - Downloads specified version
   - Installs
   - Starts

**Purpose:**
Update to specific version when you know exactly which version is needed.

**When to use:**
- To install specific version
- When step 13 can't determine version from logs
- For manual update per project team instructions
- To rollback to older version (downgrade)

**Usage example:**
- On Discord/Twitter team announced: "Update nodes to version 1.2.5"
- You select option 14
- Enter: `1.2.5`
- Node updates

---

### 15) ⬇️ Restore Previous Version

**What it does:**

1. **Searches Backups:**
   - Looks for files like: `/usr/bin/stabled.bak-YYYYMMDD-HHMMSS`
   - Sorts by creation time
   - Selects most recent backup

2. **Checks Backup Availability:**
   - If no backups - outputs error "No backups found"
   - If exists - continues

3. **Performs Rollback:**
   - Stops node: `systemctl stop stabled`
   - Copies backup back to `/usr/bin/stabled`
   - Makes file executable
   - Starts node: `systemctl start stabled`
   - Shows restored version

**Purpose:**
Return to previous working version if new version caused problems.

**When to use:**
- After update node won't start
- New version works unstably
- Critical errors appeared after update
- Incompatibility with current network state

**Important:**
- Rollback possible only if you updated via steps 13 or 14
- They automatically create backups
- Can only rollback to last previous version
- For rollback to older versions use step 14

---

### 16) 💾 Archive Critical Data

**What it does:**

1. **Installation Check:**
   - Verifies presence of `/root/.stabled/` directory
   - If node not installed - shows warning

2. **Create Temporary Folder:**
   - Creates directory `/root/stable_backups/backup_YYYY-MM-DD_HH-MM-SS/`
   - Name format with date and time for uniqueness

3. **Copy Critical Files:**
   - 🔑 `priv_validator_key.json` - **MOST IMPORTANT!** Validator private key
   - 🔑 `node_key.json` - Node key for P2P connections
   - 📊 `priv_validator_state.json` - Validator state (double-sign protection)
   - ⚙️ `config.toml` - All node settings
   - ⚙️ `app.toml` - Application settings
   - 📇 `addrbook.json` - Peer address book

4. **Archiving:**
   - Creates compressed archive `stable_backup_YYYY-MM-DD_HH-MM-SS.tar.gz`
   - Removes temporary folder
   - Keeps only the archive

5. **Save Information:**
   - Shows path to created archive
   - Provides command to download to local PC

**Purpose:**

Protection against node access loss in case of:
- 💥 Server failure (disk failure, OS crash)
- 🔥 Accidental file deletion
- 🌪️ Data corruption
- 🚀 Migration to new server
- 🔄 System reinstallation

**When to use:**

1. **Mandatory:**
   - ✅ Right after first node installation (step 2)
   - ✅ After any critical configuration changes
   - ✅ Before system update
   - ✅ Before applying snapshot (step 10)

2. **Recommended:**
   - 📅 Regularly (weekly or monthly)
   - 🔧 Before node update (steps 13, 14)
   - 🛠️ Before any experiments with settings

3. **Just in case:**
   - Periodically for peace of mind

**Technical Information:**

```bash
# Backup structure:
/root/stable_backups/
└── stable_backup_2024-11-20_15-30-45.tar.gz
    ├── priv_validator_key.json    (~300 bytes)
    ├── node_key.json               (~200 bytes)
    ├── priv_validator_state.json  (~150 bytes)
    ├── config.toml                 (~25 KB)
    ├── app.toml                    (~20 KB)
    └── addrbook.json               (~5-50 KB)

# Total archive size: ~50-100 KB
```

**How to Download Backup to Your Computer:**

After creating backup, script will show command like:
```bash
scp root@YOUR_SERVER_IP:/root/stable_backups/stable_backup_2024-11-20_15-30-45.tar.gz ./
```

**On Windows** use WinSCP or command in PowerShell:
```powershell
scp root@YOUR_SERVER_IP:/root/stable_backups/stable_backup_*.tar.gz C:\backups\
```

**Restore from Backup:**

If you need to restore node:
```bash
# 1. Extract archive
cd /root/stable_backups/
tar -xzf stable_backup_2024-11-20_15-30-45.tar.gz

# 2. Stop node
systemctl stop stabled

# 3. Restore files
cp backup_2024-11-20_15-30-45/priv_validator_key.json /root/.stabled/config/
cp backup_2024-11-20_15-30-45/node_key.json /root/.stabled/config/
cp backup_2024-11-20_15-30-45/priv_validator_state.json /root/.stabled/data/
cp backup_2024-11-20_15-30-45/config.toml /root/.stabled/config/
cp backup_2024-11-20_15-30-45/app.toml /root/.stabled/config/

# 4. Start node
systemctl start stabled
```

**⚠️ CRITICALLY IMPORTANT:**

1. **Store backups in SAFE place:**
   - ✅ On local computer (encrypted disk)
   - ✅ In cloud storage (encrypted archive)
   - ✅ On external drive (USB)
   - ❌ DO NOT store only on server!

2. **Loss of `priv_validator_key.json` means:**
   - ❌ Complete loss of node access
   - ❌ Impossible to recover
   - ❌ Loss of all rewards (if any)

3. **DO NOT share backups:**
   - ❌ Don't send to anyone
   - ❌ Don't publish on internet
   - ❌ Don't store in public places

**Usage Examples:**

```bash
# Scenario 1: After installation
2) ⚙️  Install node
3) 🚀 Start node
16) 💾 Create keys backup ← IMMEDIATELY AFTER INSTALL!

# Scenario 2: Before snapshot
16) 💾 Create keys backup
10) 📸 Apply snapshot

# Scenario 3: Regular maintenance
16) 💾 Create keys backup (weekly)
```

**When NOT to use:**
- ❌ If node not installed (step 2 not done yet)
- ❌ No special need to make 10 backups per day

---

### 0) ❌ Terminate

**What it does:**
- Terminates script execution
- Returns you to command line

**Purpose:**
Exit node management menu.

**When to use:**
- After completing all operations
- When need to execute other commands in terminal

---

## 🎯 Typical Usage Scenarios

### Scenario 1: First Node Installation
1. `1) 📦 Prepare server` - install dependencies
2. `2) ⚙️ Install node` - install and configure (choose `y` for snapshot)
3. `3) 🚀 Start node` - launch
4. Wait 10-15 minutes
5. `9) 💚 Health check` - ensure everything works

### Scenario 2: Node Behind Network
1. `9) 💚 Health check` - check catching_up
2. If catching_up long `true`:
3. `10) 📸 Apply snapshot` - quick sync
4. `6) 🔄 Restart node`
5. `9) 💚 Health check` - check result

### Scenario 3: Low Peer Count
1. `9) 💚 Health check` - saw < 3 peers
2. `12) 🌐 Update peers` - update list (press Enter for backups)
3. Wait 1-2 minutes
4. `9) 💚 Health check` - check peer count

### Scenario 4: Update Required
1. `4) 📜 Node logs` - saw message "Upgrade to v1.x.x"
2. `13) 🤖 Auto-upgrade` - update automatically
3. Or `14) ⬆️ Manual upgrade` - specify version
4. `8) 🏷️ Node version` - check new version
5. `9) 💚 Health check` - ensure operability

### Scenario 5: Automation Setup
1. `11) ⏰ Auto-snapshot`
2. Choose `1) Install/Update timer`
3. Specify time (e.g., 02:00)
4. Choose `4) Status` - check setup
5. `0) Back` - return to main menu

---

## 📊 Additional Information

### Important Paths and Files:
- **Binary file:** `/usr/bin/stabled`
- **Node data:** `/root/.stabled/`
- **Config:** `/root/.stabled/config/config.toml`
- **App config:** `/root/.stabled/config/app.toml`
- **Genesis:** `/root/.stabled/config/genesis.json`
- **Systemd service:** `/etc/systemd/system/stabled.service`
- **Snapshot helper:** `/usr/local/bin/stable-apply-snapshot.sh`

### Useful Commands Outside Menu:
```bash
# Check sync via RPC
curl -s localhost:26657/status | jq .result.sync_info.catching_up

# Current block height
curl -s localhost:26657/status | jq .result.sync_info.latest_block_height

# Peer count
curl -s localhost:26657/net_info | jq .result.n_peers

# Direct log viewing
journalctl -u stabled -f

# Node restart
systemctl restart stabled
```

### Resource Monitoring:
For detailed statistics view use additional script:
```bash
bash stable_usage.sh
```

It will show:
- CPU load by cores
- RAM usage by process and system
- Disk space breakdown (by folders)
- Sync status
- Peer count

---

