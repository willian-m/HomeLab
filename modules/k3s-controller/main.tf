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

resource "proxmox_virtual_environment_file" "user_data_cloud_init_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/cloud-init.tftpl", {
      username           = var.username
      user_uid           = var.user_uid
      vm_password        = var.vm_password
      ssh_authorized_key = data.local_file.ssh_public_key.content
      dns_server_ip      = var.dns_server_ip
      nfs_server_ip      = var.nfs_server_ip
      omv_username       = var.omv_username
    })
    file_name = "user-data-ubuntu-k3s-controller-cloud-config.yaml"
  }

}

resource "proxmox_virtual_environment_vm" "k3s_controller_vm" {
  name        = "k3s-controller"
  node_name   = var.node_name
  description = "Machine used as K3s controller. Managed by Terraform"
  tags        = ["terraform", "ubuntu", "k3s"]


  agent {
    enabled = true
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 16384
  }

  # # Use UEFI for Alpine Cloud Image
  # bios = "ovmf"

  # efi_disk {
  #   datastore_id = "local-lvm"
  #   file_format  = "raw"
  #   type         = "4m"
  # }

  # 16 GB for system disk
  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 16
  }

  initialization {

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
    bridge      = "vmbr0"
    mac_address = "BC:41:5B:41:F2:F9"
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
  node_name    = "titanium"
  url          = var.ubuntu_base_img_addr
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "k3s-controller-noble-server-cloudimg-amd64.qcow2"
}
