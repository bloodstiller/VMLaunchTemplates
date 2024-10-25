#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [-v <8|10|11>] [-n <vm_name>] [-i <iso_path>] [-s <disk_size>] [-r <ram>] [-c <cpus>]"
    echo "  -v: Windows version (7, 8, 10, or 11)"
    echo "  -n: VM name"
    echo "  -i: Path to Windows ISO"
    echo "  -s: Disk size (e.g., 50G)"
    echo "  -r: RAM size (e.g., 4G)"
    echo "  -c: Number of CPUs"
    exit 1
}

# Default values
WIN_VERSION="10"
VM_NAME="WindowsVM"
ISO_PATH=""
DISK_SIZE="50G"
RAM="4G"
CPUS="2"

# Parse command line options
while getopts "v:n:i:s:r:c:" opt; do
    case $opt in
        v) WIN_VERSION=$OPTARG ;;
        n) VM_NAME=$OPTARG ;;
        i) ISO_PATH=$OPTARG ;;
        s) DISK_SIZE=$OPTARG ;;
        r) RAM=$OPTARG ;;
        c) CPUS=$OPTARG ;;
        *) usage ;;
    esac
done

# Validate Windows version
case $WIN_VERSION in
    7|8|10|11) ;;
    *) echo "Invalid Windows version. Use 7, 8, 10, or 11."; exit 1 ;;
esac

# Check if ISO path is provided
if [ -z "$ISO_PATH" ]; then
    echo "ISO path is required. Use -i option."
    exit 1
fi

ANSWER_FILE="autounattend_win${WIN_VERSION}.xml"

# Create a new disk image
qemu-img create -f qcow2 ${VM_NAME}.qcow2 ${DISK_SIZE}

# Create a virtual floppy disk with the answer file
qemu-img create -f raw floppy.img 1440K
mkfs.msdos -C floppy.img 1440
mcopy -i floppy.img ${ANSWER_FILE} ::autounattend.xml

# QEMU command
QEMU_CMD="qemu-system-x86_64 \
    -name ${VM_NAME} \
    -enable-kvm \
    -m ${RAM} \
    -smp ${CPUS} \
    -cpu host \
    -hda ${VM_NAME}.qcow2 \
    -cdrom ${ISO_PATH} \
    -fda floppy.img \
    -boot d \
    -device virtio-net,netdev=net0 \
    -netdev user,id=net0 \
    -vga virtio \
    -display sdl,gl=on"

# Add specific options for Windows 11
if [ "$WIN_VERSION" = "11" ]; then
    QEMU_CMD+=" -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time"
    QEMU_CMD+=" -device virtio-vga-gl"
    QEMU_CMD+=" -device qemu-xhci -device usb-kbd -device usb-tablet"
    QEMU_CMD+=" -device intel-hda -device hda-duplex"
    QEMU_CMD+=" -smbios type=0,vendor=QEMU,version=1.0"
    QEMU_CMD+=" -smbios type=1,manufacturer=QEMU,product=Standard PC (Q35 + ICH9, 2009),version=1.0,serial=1234,uuid=00000000-0000-4000-8000-000000000001"
    QEMU_CMD+=" -smbios type=2,manufacturer=QEMU,product=Standard PC (Q35 + ICH9, 2009),version=1.0,serial=1234"
    QEMU_CMD+=" -smbios type=3,manufacturer=QEMU,version=1.0,serial=1234"
fi

# Start the VM
eval $QEMU_CMD