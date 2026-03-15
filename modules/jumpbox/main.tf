terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_oci_image" "jumpbox_img" {
  node_name    = var.node_name
  datastore_id = "local"
  reference    = "ghcr.io/tailscale/caddy-tailscale:main"
  file_name    = "${var.hostname}-latest.tar"
  overwrite    = true
}


resource "proxmox_virtual_environment_container" "jumpbox" {
  node_name       = var.node_name
  tags            = ["gateway", "terraform"]
  vm_id = var.jumpbox_id

  unprivileged = true
  features {
    nesting = false
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_oci_image.jumpbox_img.id
  }

  console {
    enabled = false
  }

  memory {
    dedicated = 512
  }

  initialization {
    hostname = var.hostname
    ip_config {
      ipv4 {
        address = "${var.ipv4_address}"
        gateway = "${var.ipv4_gateway}"
      }
      ipv6 {
        address = "${var.ipv6_address}"
        gateway = "${var.ipv6_gateway}"
      }
    }
  }

  network_interface {
    name = "veth0"
    bridge = "vmbr0"
    mac_address = "BC:24:11:7B:1A:3C"
  }


  disk {
    datastore_id = "local-lvm"
    size    = 1
  }

  # volume mounts
  mount_point {
    volume = "ExternalHardDisk"
    size   = "1G"
    path   = "/config"
    backup = true
  }

    # volume mounts
  mount_point {
    volume = "ExternalHardDisk"
    size   = "1G"
    path   = "/data"
    backup = true
  }

  startup {
    order      = "2"
    up_delay   = "15"
    down_delay = "60"
  }

  start_on_boot = true

}

resource "local_file" "ansible_inventory_jumpbox" {
  content = templatefile("${path.module}/inventory.tftpl", {
    node_name = var.node_name
    ipv4_proxmox = var.ipv4_proxmox
  })

  filename = "${path.module}/../../ansible/inventory/jumpbox.yml"
}

resource "local_file" "ansible_playbook_jumpbox" {
  content = templatefile("${path.module}/playbook.tftpl", {
    tailscale_auth_key = var.tailscale_auth_key
    hostname = var.hostname
    ipv4_proxmox = var.ipv4_proxmox
    jumpbox_id = var.jumpbox_id
    ipv4_dns = split("/",var.ipv4_dns)[0]
  })

  filename = "${path.module}/../../ansible/playbooks/jumpbox.yml"
}

resource "null_resource" "ansible_provision_jumpbox" {
  depends_on = [
    local_file.ansible_inventory_jumpbox,
    local_file.ansible_playbook_jumpbox,
    proxmox_virtual_environment_container.jumpbox,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i ${local_file.ansible_inventory_jumpbox.filename} ${local_file.ansible_playbook_jumpbox.filename} \
      --ssh-extra-args='-o StrictHostKeyChecking=no'
    EOT
  }
}