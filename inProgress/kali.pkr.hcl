source "qemu" "kali" {
  iso_url           = "https://cdimage.kali.org/kali-2023.1/kali-linux-2023.1-installer-amd64.iso"
  iso_checksum      = "sha256:abc123..." // Replace with actual checksum
  output_directory  = "output_kali_qemu"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_size         = "50G"
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  ssh_username      = "kali"
  ssh_password      = "kali"
  ssh_timeout       = "20m"
  vm_name           = "kali-base"
  memory            = "4096"
  cpus              = "2"
}

build {
  sources = ["source.qemu.kali"]

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
  }
}
