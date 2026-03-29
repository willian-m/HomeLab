resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    ipv4_k3s_controller =  var.ipv4_k3s_controller
    username = var.username
  })
  filename = "${path.module}/../../k8s/inventory.yml"
}

resource "local_file" "ansible_playbook_registry" {
  content = templatefile("${path.module}/playbook-registry.tftpl", {
    registry_node_port = var.registry_node_port
    allocated_registry_storage = var.allocated_registry_storage
  })
  filename = "${path.module}/../../k8s/registry/playbook.yml"
}

resource "local_file" "ansible_playbook_cups" {
  content = templatefile("${path.module}/playbook-cups.tftpl", {
    tailnet_dns_name = var.tailnet_dns_name
    jumpbox-hostname = var.jumpbox_hostname
  })
  filename = "${path.module}/../../k8s/cups/playbook.yml"
}