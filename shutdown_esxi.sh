#!/bin/sh

#log file----------------------------------------------------------------------------------
LOGFILE="/vmfs/volumes/datastore1/scripts/logfile.log"

#logger function----------------------------------------------------------------------------------
log_message() {
    local message=$1
    logger -t datacenter_shutdown "$message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOGFILE
}

#gracefully shutdown a VM----------------------------------------------------------------------------------
shutdown_vm() {
    vmid=$1
    log_message "Attempting to gracefully shut down VMID: $vmid"
    vim-cmd vmsvc/power.shutdown $vmid
    sleep 5
    state=$(vim-cmd vmsvc/power.getstate $vmid | tail -1)

    if [ "$state" != "Powered off" ]; then
        log_message "Graceful shutdown failed for VMID: $vmid. Forcing power off."
        vim-cmd vmsvc/power.off $vmid
    else
        log_message "VMID: $vmid shut down gracefully."
    fi
}

#loop over every running VM----------------------------------------------------------------------------------
for vm in $(vim-cmd vmsvc/getallvms | grep "^[0-9]" | awk '{print $1}'); do
    shutdown_vm $vm
done

#make sure every VM is "Powered off"----------------------------------------------------------------------------------
all_vms_off=0
while [ $all_vms_off -ne 1 ]; do
    all_vms_off=1
    for vm in $(vim-cmd vmsvc/getallvms | grep "^[0-9]" | awk '{print $1}'); do
        state=$(vim-cmd vmsvc/power.getstate $vm | tail -1)
        if [ "$state" = "Powered on" ]; then
            all_vms_off=0
            break
        fi
    done
    if [ $all_vms_off -ne 1 ]; then
	log_message "Waiting for all VMs to power off..."
        sleep 10
    fi
done

#Enter maintenance mode----------------------------------------------------------------------------------
log_message "Entering maintenance mode."
vim-cmd hostsvc/maintenance_mode_enter

#Shutdown ESXi host----------------------------------------------------------------------------------
log_message "Shutting down ESXi host in 60 seconds."
esxcli system shutdown poweroff -d 60 -r "Scheduled shutdown"

