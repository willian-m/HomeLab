output "dev_vm_ipv4_address" {
  description = "The IPv4 address of the development VM"
  value = proxmox_virtual_environment_vm.ubuntu_dev_vm.ipv4_addresses[1][0]
}

output "dev_vm_id" {
  description = "The VM ID of the development VM"
  value       = proxmox_virtual_environment_vm.ubuntu_dev_vm.vm_id
}

output "dev_vm_ssh_command" {
  description = "SSH command to connect to the development VM"
  value       = "ssh ${var.username}@${proxmox_virtual_environment_vm.ubuntu_dev_vm.ipv4_addresses[1][0]}"
}