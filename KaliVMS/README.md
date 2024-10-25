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

## The kali_setup.sh Script

The `kali_setup.sh` script is designed to automate the initial setup and customization of your Kali Linux VM. This script is automatically copied to the shared folder during the VM creation process.

### Features of kali_setup.sh

- Updates the system packages
- Installs additional tools and software
- Configures system settings
- Sets up user preferences

### Customizing kali_setup.sh

You can modify the `kali_setup.sh` script to suit your specific needs. Some common customizations include:

- Installing additional packages
- Configuring network settings
- Setting up development environments
- Adding custom aliases or shell configurations

To customize the script:

1. Open the `kali_setup.sh` file in a text editor
2. Add or modify commands as needed
3. Save the file before running the VM launch script

### Running kali_setup.sh

After launching your Kali VM:

1. Open a terminal in the VM
2. Navigate to the mounted shared folder:
   ```
   cd /mnt/host_share
   ```
3. Make the script executable (if not already):
   ```
   chmod +x kali_setup.sh
   ```
4. Run the script with sudo:
   ```
   sudo ./kali_setup.sh
   ```

Note: Always review the contents of `kali_setup.sh` before running it to ensure it meets your requirements and doesn't contain any unintended operations.

## Customization

- Modify `kali_setup.sh` to customize the VM setup process.
- Adjust VM specifications (RAM, CPU cores) in the script as needed.

## Logging

The script creates a log file in the same directory, named `Kali-YYYY-MM-DD-log.txt`, which contains details about the VM creation process.


