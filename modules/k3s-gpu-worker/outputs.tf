output "k3s_gpu_worker_ipv4_address" {
  description = "The IPv4 address of the K3s controller VM"
  value       = proxmox_virtual_environment_vm.k3s_gpu_worker_vm.ipv4_addresses[1][0]
}

output "k3s_gpu_worker_vm_id" {
  description = "The VM ID of the K3s controller VM"
  value       = proxmox_virtual_environment_vm.k3s_gpu_worker_vm.vm_id
}

output "k3s_gpu_worker_vm_ssh_command" {
  description = "SSH command to connect to the K3s controller VM"
  value       = "ssh ${var.username}@${proxmox_virtual_environment_vm.k3s_gpu_worker_vm.ipv4_addresses[1][0]}"
}
