output "dev_vm_ssh_command" {
  description = "The IPv4 address of the development VM"
  value       = module.dev_vm.dev_vm_ssh_command
}

output "dev_vm_id" {
  description = "The VM ID of the development VM"
  value       = "Dev VM created with id ${module.dev_vm.dev_vm_id}"
}