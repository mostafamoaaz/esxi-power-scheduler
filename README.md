# ESXi Scheduled Shutdown & Auto-Startup Scripts

This repository provides a simple automation solution for startups or small environments (especially in regions like Egypt with regular power outages) to safely shut down and restore VMware ESXi hosts and virtual machines, in the absence of a UPS.

## 📄 Files Overview

- `shutdown_esxi.sh` – Safely shuts down all running VMs and the ESXi host.
- `local.sh` – Automatically powers on VMs and restores cron jobs after reboot.
- `README.md` – This file.

## ⚙️ Installation Instructions

> ⚠️ This setup assumes your datastore is named `datastore1`. Modify paths if different.

1. **Copy the files to your datastore**:

```bash
cp shutdown_esxi.sh /vmfs/volumes/datastore1/scripts/
```
2. **Edit the local.sh startup script:**:

```bash
vi /etc/rc.local.d/local.sh
```
3. **Make both scripts executable**:

```bash
chmod +x /vmfs/volumes/datastore1/scripts/shutdown_esxi.sh
chmod +x /etc/rc.local.d/local.sh
```
4. **Adjust the cron job time in local.sh**:
Append this line to `/var/spool/cron/crontabs/root` (or let `local.sh` handle it automatically):

```bash
CRON_LINE="50 13 * * * /vmfs/volumes/datastore1/scripts/shutdown_esxi.sh"
```

5. **Restart the cron service**:
You must restart the cron daemon after editing the crontab. Since ESXi doesn’t include standard service management tools, you can do it manually:
```bash
kill $(pidof crond)
crond
```
> ⚠️ If the setup doesn’t work as expected the first time, simply restart the ESXi host once.
On subsequent boots, local.sh will auto-reload the cron entry if missing.

🔐 Requirements
- VMware ESXi host (tested on 6.7+)

- Scripts must be stored on a persistent datastore

- Root access to modify cron jobs and local.sh

- vim-cmd and esxcli tools must be available

- Crond must be running for scheduled jobs

> ⚠️ Warnings
These scripts directly affect production VMs and host shutdown. Use at your own risk.

Not tested with UEFI Secure Boot — local.sh will not run if Secure Boot is enabled.