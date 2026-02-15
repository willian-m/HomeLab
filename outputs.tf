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

output "k3s_remote_access_instructions" {
  description = "Commands to allow remote access into the cluster from your workstation"
  value       = <<-EOT
    # Run these commands on your workstation or bastion server:
    export SERVER_IP=${module.k3s_controller.k3s_controller_ipv4_address}
    scp ${var.k3s_controller_username}@$SERVER_IP:/etc/rancher/k3s/k3s.yaml ~/.kube/config && \
    sed -i "s/127.0.0.1/$SERVER_IP/g" ~/.kube/config

    # Automatically add KUBECONFIG to your shell profile if not already present
    SHELL_PROFILE=$([ -f "$HOME/.zshrc" ] && echo "$HOME/.zshrc" || echo "$HOME/.bashrc")
    if ! grep -q "KUBECONFIG" "$SHELL_PROFILE"; then
      echo 'export KUBECONFIG=$HOME/.kube/config' >> "$SHELL_PROFILE"
      echo "Success: KUBECONFIG export added to $SHELL_PROFILE"
    else
      echo "Note: KUBECONFIG already present in $SHELL_PROFILE"
    fi
    export KUBECONFIG=$HOME/.kube/config
  EOT
}
