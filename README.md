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
