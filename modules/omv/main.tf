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

resource "null_resource" "create_user_infrastructure" {
  provisioner "local-exec" {
    command = <<-EOT
      ssh root@${var.proxmox_host} bash << 'ENDSSH'

        # --- Create user for dev image
        current_uid=$(id -u ${var.username})
        if [[ $current_uid != ${var.user_uid} ]]; then
          adduser --system --no-create-home --uid ${var.user_uid} ${var.username}
        fi
        mkdir -p /mnt/ExternalHardDisk/services/omv-storage
        chown ${var.username}:nogroup /mnt/ExternalHardDisk/services/omv-storage
      ENDSSH
    EOT
  }
}

resource "proxmox_virtual_environment_hardware_mapping_dir" "omv_storage" {
  comment = "Directory for main storage of OMV"
  name    = "omv-storage"
  depends_on = [
    null_resource.create_user_infrastructure,
  ]

  map = [
    {
      node = var.node_name
      path = "/mnt/ExternalHardDisk/services/omv-storage"
    },
  ]
}

resource "proxmox_virtual_environment_file" "user_data_cloud_init_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data      = templatefile("${path.module}/cloud-init.tftpl", {
      username            = var.username
      user_uid            = var.user_uid
      vm_password         = var.vm_password
      ssh_authorized_key  = data.local_file.ssh_public_key.content
      dns_server_ip       = var.dns_server_ip
    })
    file_name = "user-data-debian-omv-cloud-config.yaml"
  }

}

resource "proxmox_virtual_environment_vm" "omv_vm" {
  name        = "omv"
  node_name   = var.node_name
  description = "Machine used for dev purposes. Managed by Terraform"
  tags        = ["terraform", "debian", "nfs"]


  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 8192
  }

  # 16 GB for system disk
  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 16
  }

  # Mount dev-projects 
  virtiofs {
    mapping      = proxmox_virtual_environment_hardware_mapping_dir.omv_storage.id
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
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
      ipv6 {
        address = var.ipv6_address
        gateway = var.ipv6_gateway
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_init_config.id
  }

  network_device {
    bridge = "vmbr0"
    mac_address = "BC:41:5B:41:F2:F8"
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

resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "titanium"
  url          = var.debian_base_img_addr
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "debian-server-cloudimg-amd64.qcow2"
}

resource "local_file" "ansible_inventory_omv" {
  content = templatefile("${path.module}/inventory.tftpl", {
    host_ip = proxmox_virtual_environment_vm.omv_vm.ipv4_addresses[1][0]
    username = var.username
  })

  filename = "${path.module}/../../ansible/inventory/omv.yml"
}

resource "local_file" "ansible_playbook_omv" {
  content = templatefile("${path.module}/playbook.tftpl", {
    tailscale_auth_key = var.tailscale_auth_key
    username           = var.username
    dns_server_ip      = var.dns_server_ip
  })

  filename = "${path.module}/../../ansible/playbooks/omv.yml"
}

resource "null_resource" "ansible_provision_omv" {
  depends_on = [
    local_file.ansible_inventory_omv,
    local_file.ansible_playbook_omv,
    proxmox_virtual_environment_vm.omv_vm,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i ${local_file.ansible_inventory_omv.filename} ${local_file.ansible_playbook_omv.filename} \
      --ssh-extra-args='-o StrictHostKeyChecking=no' --ask-become-pass
    EOT
  }
}