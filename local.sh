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

# Function to log messages
log_message() {
    local message=$1
    logger -t datacenter_shutdown "$message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOGFILE
}

# Exit maintenance mode
log_message "Exitting maintenance mode"
vim-cmd hostsvc/maintenance_mode_exit

# Get VM IDs with autostart enabled
vim-cmd hostsvc/autostartmanager/get_autostartseq | grep 'vim.VirtualMachine:' | while read -r line; do
    vmid=$(echo $line | sed 's/.*vim.VirtualMachine:\([0-9]*\).*/\1/')
    start_action=$(vim-cmd hostsvc/autostartmanager/get_autostartseq | grep -A 4 "vim.VirtualMachine:$vmid" | grep 'startAction = "powerOn"')
    if [ -n "$start_action" ]; then
        log_message "Powering on VM with ID: $vmid"
        vim-cmd vmsvc/power.on $vmid
    fi
done


# Re-add cron job after reboot
#PLEASE ADJUST THE TIME IN CRONJOB TO WHAT YOU P
CRON_LINE="50 13 * * * /vmfs/volumes/datastore1/scripts/shutdown_esxi.sh"
CRON_FILE="/var/spool/cron/crontabs/root"

# Check if it's already in cron; if not, add it
grep -F "$CRON_LINE" "$CRON_FILE" > /dev/null 2>&1 || echo "$CRON_LINE" >> "$CRON_FILE"



exit 0
