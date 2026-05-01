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
        STORAGE_FOLDER=/mnt/ExternalHardDisk/services/openclaw-data
        current_uid=$(id -u openclaw)
        if [[ $current_uid != ${var.user_uid} ]]; then
          adduser --system --no-create-home --uid ${var.user_uid} openclaw
        fi
        mkdir -p $STORAGE_FOLDER
        chown openclaw:nogroup $STORAGE_FOLDER
      ENDSSH
    EOT
  }
}

resource "proxmox_virtual_environment_hardware_mapping_dir" "openclaw_data" {
  comment = "Directory for storing development projects"
  name    = "openclawData"
  depends_on = [
    null_resource.create_user_infrastructure,
  ]

  map = [
    {
      node = var.node_name
      path = "/mnt/ExternalHardDisk/services/openclaw-data"
    },
  ]
}


resource "proxmox_virtual_environment_file" "user_data_cloud_init_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data      = templatefile("${path.module}/cloud-init.tftpl", {
      user_uid            = var.user_uid
      ssh_authorized_key  = data.local_file.ssh_public_key.content
      vm_password         = var.vm_password
    })
    file_name = "user-data-ubuntu-openclaw-cloud-config.yaml"
  }

}

resource "proxmox_virtual_environment_vm" "openclaw_vm" {
  name        = "openclaw-vm"
  node_name   = var.node_name
  description = "Machine used for isolating openclaw. Managed by Terraform"
  tags        = ["terraform", "ubuntu", "openclaw", "ai"]


  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
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
    mapping      = proxmox_virtual_environment_hardware_mapping_dir.openclaw_data.id
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
    mac_address = "BC:24:11:CE:8B:F9"
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
  node_name    = var.node_name
  url          = var.ubuntu_base_img_addr
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "openclawvm-noble-server-cloudimg-amd64.qcow2"
}