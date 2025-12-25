output "dev_vm_ipv4_address" {
  description = "The IPv4 address of the development VM"
  value = proxmox_virtual_environment_vm.ubuntu_dev_vm.ipv4_addresses[1][0]
}