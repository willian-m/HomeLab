resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    ipv4_k3s_controller = split("/",var.ipv4_k3s_controller)[0]
    ipv4_k3s_gpu_node   = split("/",var.ipv4_k3s_gpu)[0]
    username = var.username
  })
  filename = "${path.module}/../../k8s/inventory.yml"
}

resource "local_file" "ansible_playbook_registry" {
  content = templatefile("${path.module}/playbook-registry.tftpl", {
    registry_node_port = var.registry_node_port
    allocated_registry_storage = var.allocated_registry_storage
    tailnet_dns_name = var.tailnet_dns_name
    jumpbox-hostname = var.jumpbox_hostname
    ipv4_dns = split("/",var.ipv4_dns)[0]
    ipv4_gateway = split("/",var.ipv4_gateway)[0]
    ipv4_k3s_controller = split("/",var.ipv4_k3s_controller)[0]
  })
  filename = "${path.module}/../../k8s/registry/playbook.yml"
}

resource "local_file" "cups_sealed_secret" {
  content = templatefile("${path.module}/cups-sealed-secret.tftpl",{
    CUPSADMIN_ENCRYPTED=var.CUPSADMIN_ENCRYPTED
    CUPSPASSWORD_ENCRYPTED=var.CUPSPASSWORD_ENCRYPTED
  })
  filename = "${path.module}/../../k8s/cups/sealed-secret.yml"
}

resource "local_file" "cups_deployment" {
  content = templatefile("${path.module}/cups-deployment.tftpl",{
    jumpbox_hostname=var.jumpbox_hostname
    tailnet_dns_name=var.tailnet_dns_name
  })
  filename = "${path.module}/../../k8s/cups/deployment.yml"
}

resource "local_file" "ansible_playbook_cups" {
  content = templatefile("${path.module}/playbook-cups.tftpl", {
    tailnet_dns_name = var.tailnet_dns_name
    jumpbox-hostname = var.jumpbox_hostname
  })
  filename = "${path.module}/../../k8s/cups/playbook.yml"
}