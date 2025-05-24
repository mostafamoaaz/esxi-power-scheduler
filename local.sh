# local configuration options

# Note: modify at your own risk!  If you do/use anything in this
# script that is not part of a stable API (relying on files to be in
# specific places, specific tools, specific output, etc) there is a
# possibility you will end up with a broken system after patching or
# upgrading.  Changes are not supported unless under direction of
# VMware support.

# Note: This script will not be run when UEFI secure boot is enabled.
# Define log file
LOGFILE="/vmfs/volumes/datastore1/scripts/logfile.log"

LOG_DIR=$(dirname "$LOGFILE")
[ -d "$LOG_DIR" ] || mkdir -p "$LOG_DIR"

# Function to log messages
log_message() {
    local message=$1
    logger -t datacenter_shutdown "$message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOGFILE
}

# Exit maintenance mode
log_message "Exiting maintenance mode"

if ! vim-cmd hostsvc/maintenance_mode_exit; then
    log_message "ERROR: Failed to exit maintenance mode"
    exit 1
fi

# Get VM IDs with autostart enabled
vim-cmd hostsvc/autostartmanager/get_autostartseq | grep 'vim.VirtualMachine:' | while read -r line; do
    vmid=$(echo $line | sed 's/.*vim.VirtualMachine:\([0-9]*\).*/\1/')
    start_action=$(vim-cmd hostsvc/autostartmanager/get_autostartseq | grep -A 4 "vim.VirtualMachine:$vmid" | grep 'startAction = "powerOn"')
    if [ -n "$start_action" ]; then
        log_message "Powering on VM with ID: $vmid"
        if ! vim-cmd vmsvc/power.on "$vmid"; then
            log_message "ERROR: Failed to power on VM $vmid"
        fi
    fi
done


# Re-add cron job after reboot
# PLEASE ADJUST THE TIME IN CRONJOB TO WHAT YOU PLEASE
CRON_LINE="50 13 * * * /vmfs/volumes/datastore1/scripts/shutdown_esxi.sh"
CRON_FILE="/var/spool/cron/crontabs/root"

# careful with using this line as typically cron file contain already crucial jobs
#[ -f "$CRON_FILE" ] || touch "$CRON_FILE"

# Only append if the line doesn't already exist
if [ -f "$CRON_FILE" ] && ! grep -Fxq "$CRON_LINE" "$CRON_FILE"; then
    echo "$CRON_LINE" >> "$CRON_FILE"
    log_message "Added shutdown schedule to cron file"
else
    log_message "Shutdown schedule already exists or cron file missing"
fi
