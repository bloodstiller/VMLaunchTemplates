#!/bin/bash

# Variables
VM_NAME="Kali"
QCOW_IMAGE="/home/martin/Hacking/VMS/VirtManagerMachines/Kali_Base/kali-linux-2023.1-qemu-amd64-clone-1.qcow2"
STORAGE_IMAGE="/home/martin/Hacking/VMS/VirtManagerMachines/Kali_Base/Kali-Sata-Storage.qcow2"
RAM="8G"
CORES=6
SETUP_SCRIPT="/path/to/kali_setup.sh"

# Check if the base image exists
if [ ! -f "$QCOW_IMAGE" ]; then
    echo "Error: Base QCOW2 image not found at $QCOW_IMAGE"
    exit 1
fi

# Check if the storage image exists
if [ ! -f "$STORAGE_IMAGE" ]; then
    echo "Error: Storage QCOW2 image not found at $STORAGE_IMAGE"
    exit 1
fi

# Check if the setup script exists
if [ ! -f "$SETUP_SCRIPT" ]; then
    echo "Error: Setup script not found at $SETUP_SCRIPT"
    exit 1
fi

# Launch the VM
qemu-system-x86_64 \
    -name "$VM_NAME" \
    -enable-kvm \
    -cpu host \
    -smp cores=$CORES \
    -m $RAM \
    -machine pc-q35-7.2,accel=kvm \
    -drive file="$QCOW_IMAGE",format=qcow2,if=virtio \
    -drive file="$STORAGE_IMAGE",format=qcow2,if=virtio \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:fc:43:42 \
    -netdev user,id=net1 \
    -device virtio-net-pci,netdev=net1,mac=52:54:00:f6:bb:d6 \
    -vga virtio \
    -display spice-app,gl=on \
    -device virtio-serial \
    -chardev spicevmc,id=vdagent,name=vdagent \
    -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
    -device usb-tablet \
    -device intel-hda \
    -device hda-duplex \
    -device virtio-balloon \
    -device virtio-rng-pci \
    -boot order=c \
    -fsdev local,security_model=passthrough,id=fsdev0,path=$(dirname "$SETUP_SCRIPT") \
    -device virtio-9p-pci,fsdev=fsdev0,mount_tag=host_setup \
    -serial stdio

echo "Kali VM launched. Use spice client to connect."