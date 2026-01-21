output "dev_vm_ssh_command" {
  description = "The IPv4 address of the development VM"
  value       = module.dev_vm.dev_vm_ssh_command
}

output "dev_vm_id" {
  description = "The VM ID of the development VM"
  value       = "Dev VM created with id ${module.dev_vm.dev_vm_id}"
}

output "adguard_network_ip" {
  description = "The IP address assigned to the AdGuard Home container"
  value       = module.dns.adguard_network_ip
}