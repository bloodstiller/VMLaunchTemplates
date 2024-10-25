#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Variables
TODAY_DATE=$(date +"%Y-%m-%d")
VM_NAME="Kali-$TODAY_DATE"
BASE_QCOW_IMAGE="/run/media/martin/2TB/VMS/Templates/KaliVMTemplate/kali-linux-2024.3.qcow2"
PRODUCTION_DIR="/run/media/martin/2TB/VMS/ProductionMachines"
NEW_VM_DIR="$PRODUCTION_DIR/$VM_NAME"
NEW_QCOW_IMAGE="$NEW_VM_DIR/kali-linux-2024.3.qcow2"
RAM="8192"
CORES=6
SETUP_SCRIPT="$SCRIPT_DIR/kali_setup.sh"
LOG_FILE="$SCRIPT_DIR/$VM_NAME-log.txt"
SHARED_FOLDER="$NEW_VM_DIR/shared"
DROPBOX_FOLDER="/home/martin/Dropbox"
TEST_MODE=false

# Function for logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check file permissions
check_permissions() {
    if [ ! -r "$1" ]; then
        log "Error: No read permission for $1"
        return 1
    fi
    if [ ! -w "$1" ]; then
        log "Error: No write permission for $1"
        return 1
    fi
    return 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --test) TEST_MODE=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Start logging
log "Starting Kali VM launch script"

# Check permissions for BASE_QCOW_IMAGE
if ! check_permissions "$BASE_QCOW_IMAGE"; then
    log "Exiting due to permission error"
    exit 1
fi

# Check if the setup script exists
if [ ! -f "$SETUP_SCRIPT" ]; then
    log "Error: Setup script not found at $SETUP_SCRIPT"
    exit 1
fi

# Create the new directory and shared folder
if $TEST_MODE; then
    log "[TEST] Would create directories: $NEW_VM_DIR and $SHARED_FOLDER"
else
    mkdir -p "$NEW_VM_DIR" "$SHARED_FOLDER"
    log "Created directories: $NEW_VM_DIR and $SHARED_FOLDER"
fi

# Copy the base image to the new directory with progress display
log "Copying base image to new directory..."
if $TEST_MODE; then
    log "[TEST] Would run: rsync -ah --progress $BASE_QCOW_IMAGE $NEW_QCOW_IMAGE"
else
    rsync -ah --progress "$BASE_QCOW_IMAGE" "$NEW_QCOW_IMAGE"
    log "Finished copying base image"
fi

# Copy the setup script to the shared folder
cp "$SETUP_SCRIPT" "$SHARED_FOLDER/"
log "Copied setup script to shared folder: $SHARED_FOLDER"

# Launch the VM using virt-install
if $TEST_MODE; then
    log "[TEST] Would launch VM with name: $VM_NAME"
    log "[TEST] VM configuration:"
    log "[TEST]   RAM: $RAM"
    log "[TEST]   CPUs: $CORES"
    log "[TEST]   Disk: $NEW_QCOW_IMAGE"
    log "[TEST]   Shared Folder: $SHARED_FOLDER"
    log "[TEST]   Dropbox Folder: $DROPBOX_FOLDER"
else
    log "Launching VM with name: $VM_NAME"
    sudo virt-install \
        --name "$VM_NAME" \
        --memory $RAM \
        --vcpus $CORES \
        --disk path="$NEW_QCOW_IMAGE",format=qcow2,bus=virtio \
        --import \
        --os-variant debian12 \
        --network network=default \
        --graphics spice \
        --noautoconsole \
        --filesystem source="$SHARED_FOLDER",target=host_share,mode=mapped

    log "VM launched successfully"
fi

log "Kali VM launch process completed"
echo "Kali VM launched with name $VM_NAME."
echo "The setup script has been copied to the shared folder: $SHARED_FOLDER"
echo "To access the shared folder in the VM:"
echo "1. Connect to the VM using virt-manager"
echo "2. Open a terminal in the VM"
echo "3. Run the following commands:"
echo "   sudo mkdir /mnt/host_share"
echo "   sudo mount -t 9p -o trans=virtio host_share /mnt/host_share"
echo "4. The setup script will be available at /mnt/host_share/kali_setup.sh"
echo "5. To run the setup script:"
echo "   sudo /mnt/host_share/kali_setup.sh"
echo "6. To access your Dropbox folder, use SSHFS or another file sharing method after the VM is running."
echo "7. Remember to mount the 100GB disk to /mnt/100gb"
echo "Use virt-manager to connect to the VM."
