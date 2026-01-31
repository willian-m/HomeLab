output "omv_ipv4_address" {
  description = "The IPv4 address of the OpenMediaVault VM"
  value       = proxmox_virtual_environment_vm.omv_vm.ipv4_addresses[1][0]
}

output "dev_vm_id" {
  description = "The VM ID of the OpenMediaVault VM"
  value       = proxmox_virtual_environment_vm.omv_vm.vm_id
}

output "dev_vm_ssh_command" {
  description = "SSH command to connect to the OpenMediaVault VM"
  value       = "ssh ${var.username}@${proxmox_virtual_environment_vm.omv_vm.ipv4_addresses[1][0]}"
}