output "openclaw_ipv4_address" {
  description = "The IPv4 address of the development VM"
  value       = proxmox_virtual_environment_vm.openclaw_vm.ipv4_addresses[1][0]
}

output "openclaw_id" {
  description = "The VM ID of the development VM"
  value       = proxmox_virtual_environment_vm.openclaw_vm.vm_id
}

output "openclaw_ssh_command" {
  description = "SSH command to connect to the development VM"
  value       = "ssh dev-setup@${proxmox_virtual_environment_vm.openclaw_vm.ipv4_addresses[1][0]}"
}

output "openclaw_message" {
  description = "A message instructing the user next steps"
  value       = "SSH into the VM and execute `curl -fsSL https://raw.githubusercontent.com/openclaw/openclaw-ansible/main/install.sh | bash`"
}