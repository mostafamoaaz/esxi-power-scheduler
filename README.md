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
add this line to the '/var/spool/cron/crontabs/root'
```bash
vi /var/spool/cron/crontabs/root
```
```bash
50 13 * * * /vmfs/volumes/datastore1/scripts/shutdown_esxi.sh
```
🔐 Requirements

you need to restart the crond service somehow
 **(you can search google for a way to do so.. in my case i grep the pid of crond, killed it then started the cron process again)**
 > ⚠️ incase the setup didnt work as intended the first time ..you just need to restart the esxi first time
 > ⚠️ so the the script reload crontab regularly and every thing will work just fine

VMware ESXi host (tested on ESXi 6.7+)

Scripts should reside on a persistent datastore

Ensure vim-cmd and esxcli tools are available

Root access to modify cron jobs and local.sh

⚠️ Warnings
These scripts directly affect production VMs and host state. Use at your own risk.

Not tested on UEFI Secure Boot — local.sh will not run if secure boot is enabled.

✍️ Author
Mostafa Moaaz
