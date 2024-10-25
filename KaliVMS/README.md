# Kali VM Launch Script

This script automates the process of creating and launching Kali Linux virtual machines using QEMU/KVM and libvirt. It provides an easy way to set up new Kali VMs with a shared folder for file transfer and setup scripts.

## Features

- Automatically creates a new Kali VM with a unique name based on the current date
- Copies a base Kali image to a new location for each VM
- Sets up a shared folder accessible from both the host and the VM
- Transfers the setup script to the shared folder for easy access within the VM
- Provides logging functionality to track the VM creation process
- Includes a test mode for verifying the script's logic without creating actual VMs

## Prerequisites

- QEMU/KVM and libvirt installed on your system
- A base Kali Linux QCOW2 image
- Sufficient disk space for new VM images

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/kali-vm-launch.git
   cd kali-vm-launch
   ```

2. Edit the script variables in `launch_kali_vm.sh` to match your system configuration:
   - `BASE_QCOW_IMAGE`: Path to your base Kali Linux QCOW2 image
   - `PRODUCTION_DIR`: Directory where new VM images will be stored
   - `RAM`: Amount of RAM for the VM (in MB)
   - `CORES`: Number of CPU cores for the VM

3. Make the script executable:
   ```
   chmod +x launch_kali_vm.sh
   ```

4. Run the script:
   ```
   sudo ./launch_kali_vm.sh
   ```

   For test mode (no actual VM creation):
   ```
   sudo ./launch_kali_vm.sh --test
   ```

5. After the VM is created, use virt-manager to connect to it.

6. Inside the VM, mount the shared folder:
   ```
   sudo mkdir /mnt/host_share
   sudo mount -t 9p -o trans=virtio host_share /mnt/host_share
   ```

7. Run the setup script from the shared folder:
   ```
   sudo /mnt/host_share/kali_setup.sh
   ```

## Customization

- Modify `kali_setup.sh` to customize the VM setup process.
- Adjust VM specifications (RAM, CPU cores) in the script as needed.

## Logging

The script creates a log file in the same directory, named `Kali-YYYY-MM-DD-log.txt`, which contains details about the VM creation process.

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check [issues page](https://github.com/yourusername/kali-vm-launch/issues) if you want to contribute.
