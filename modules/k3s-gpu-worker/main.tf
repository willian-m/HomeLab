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
      k3s_url            = var.k3s_url
      k3s_token          = var.k3s_token
    })
    file_name = "user-data-ubuntu-k3s-gpu-worker-cloud-config.yaml"
  }

}

resource "proxmox_virtual_environment_hardware_mapping_pci" "k3s_gpu" {
  comment = "GPU Passthrough for K3s Worker"
  name    = var.gpu_name

  map = [
    {
      node         = var.node_name
      path         = var.gpu_pci_id
      id           = var.gpu_device_id
      iommu_group  = var.gpu_iommu_group
      subsystem_id = var.gpu_subsystem_id
    }
  ]
}

resource "proxmox_virtual_environment_vm" "k3s_gpu_worker_vm" {
  name        = "k3s-gpu-worker"
  node_name   = var.node_name
  description = "Machine used as K3s GPU worker. Managed by Terraform"
  tags        = ["terraform", "ubuntu", "k3s", "gpu"]
  machine     = "q35"


  agent {
    enabled = true
  }

  cpu {
    cores = 4
    # Host CPU type is often required for passthrough to work well
    type = "host"
  }

  memory {
    dedicated = 20480
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 32 # Increased size for GPU drivers/containers
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
    mac_address = "BC:41:5B:41:F2:FA"
  }

  hostpci {
    device  = "hostpci0"
    mapping = proxmox_virtual_environment_hardware_mapping_pci.k3s_gpu.name
    pcie    = true
    rombar  = true
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

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    k3s_controller_ip   = var.k3s_controller_ip
    k3s_controller_user = var.username
  })
  filename = "${path.module}/../../ansible/inventory/k3s-gpu-worker.yml"
}

resource "local_file" "ansible_playbook" {
  content  = templatefile("${path.module}/playbook.tftpl", {
    username = var.username
    nfs_server_ip = var.nfs_server_ip
  })
  filename = "${path.module}/../../ansible/playbooks/k3s-gpu-worker.yml"
}

resource "null_resource" "ansible_provision_k3s_gpu_worker" {
    depends_on = [ local_file.ansible_inventory,
                    local_file.ansible_playbook,
                    proxmox_virtual_environment_vm.k3s_gpu_worker_vm]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.ansible_inventory.filename} ${local_file.ansible_playbook.filename} --private-key ${var.private_key_path} --ask-become-pass"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "titanium"
  url          = var.ubuntu_base_img_addr
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "k3s-gpu-worker-noble-server-cloudimg-amd64.qcow2"
}
