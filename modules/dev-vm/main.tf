data "local_file" "ssh_public_key" {
  filename = var.public_key_path
}

terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "null_resource" "create_users" {
  provisioner "local-exec" {
    command = <<-EOT
      ssh root@${var.proxmox_host} bash << 'ENDSSH'

        # --- Create user for dev image
        current_uid=$(id -u ${var.username})
        if [[ $current_uid != ${var.user_uid} ]]; then
          adduser --system --no-create-home --uid ${var.user_uid} ${var.username}
        fi
      ENDSSH
    EOT
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data      = templatefile("${path.module}/cloud-init.tftpl", {
      username            = var.username
      user_uid            = var.user_uid
      vm_password         = var.vm_password
      ssh_authorized_key  = data.local_file.ssh_public_key.content
    })
    file_name = "user-data-ubuntu-dev-vm-cloud-config.yaml"
  }

}

resource "proxmox_virtual_environment_vm" "ubuntu_dev_vm" {
  name        = "ubuntu-dev-vm"
  node_name   = "pve"
  description = "Machine used for dev purposes. Managed by Terraform"
  tags        = ["terraform", "ubuntu", "dev"]

  depends_on = [
    null_resource.create_users,
  ]

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  # 32 GB disk imported from cloud image
  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 32
  }

  # Mount dev-projects 
  virtiofs {
    mapping      = "dev-projects"
    cache        = "always"
    direct_io    = true
    expose_acl   = true
    expose_xattr = true
  }

  initialization {
    # uncomment and specify the datastore for cloud-init disk if default `local-lvm` is not available
    # datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "192.168.0.101/24"
        gateway = "192.168.0.1"
        # address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  provisioner "local-exec" {
    when = destroy

    command = <<-EOF
      echo "Stopping VM before destroy..."
      qm stop ${self.vm_id}
      sleep 5
      echo "VM stopped, proceeding with destroy"
    EOF
  }

}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"
  url          = var.ubuntu_base_img_addr
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "noble-server-cloudimg-amd64.qcow2"
}

resource "local_file" "ansible_inventory_dev_vm" {
  content = templatefile("${path.module}/inventory.tftpl", {
    host_ip = proxmox_virtual_environment_vm.ubuntu_dev_vm.ipv4_addresses[1][0]
  })

  filename = "${path.module}/../../ansible/inventory/dev-vm.yml"
}

resource "local_file" "ansible_playbook_dev_vm" {
  content = templatefile("${path.module}/playbook.tftpl", {
    tailscale_auth_key = var.tailscale_auth_key
    username           = var.username
  })

  filename = "${path.module}/../../ansible/playbooks/dev-vm.yml"
}

resource "null_resource" "ansible_provision_dev_vm" {
  depends_on = [
    local_file.ansible_inventory_dev_vm,
    local_file.ansible_playbook_dev_vm,
    proxmox_virtual_environment_vm.ubuntu_dev_vm,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i ${local_file.ansible_inventory_dev_vm.filename} ${local_file.ansible_playbook_dev_vm.filename} \
      --ssh-extra-args='-o StrictHostKeyChecking=no' --ask-become-pass
    EOT
  }
}