data "local_file" "ssh_public_key" {
  filename = "${var.public_key_path}"
}

terraform {
    required_providers {
        proxmox = {
          source  = "bpg/proxmox"
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
    data = <<-ENDOFFILE
    #cloud-config
    hostname: ubuntu-dev-vm
    timezone: America/Sao_Paulo
    users:
      - user:
        name: ${var.username}
        uid: ${var.user_uid}
        passwd: ${var.vm_password}
        groups:
          - docker
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
    apt:
      preserve_sources_list: true
      sources:
        docker.list:
          source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
          keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
          # If key expires and needs to be updated, update the keyid above with:
          # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --show-keys --fingerprint --with-colons | awk -F: '/^fpr:/ { print $10 }'
    mounts:
      - [ 'dev-projects', '/home/${var.username}/dev-projects', 'virtiofs', 'rw,default', '0', '0' ]
    package_update: true
    packages:
      - containerd.io
      - curl
      - docker-buildx-plugin
      - docker-ce
      - docker-ce-cli
      - docker-compose-plugin
      - net-tools
      - qemu-guest-agent
      - vim
      - virtiofsd
      - zsh
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - chown -R ${var.username}:${var.username} /home/${var.username}/dev-projects
      - echo "done" > /tmp/cloud-config.done
    ENDOFFILE
    file_name = "user-data-ubuntu-dev-vm-cloud-config.yaml"
  }

}

resource "proxmox_virtual_environment_vm" "ubuntu_dev_vm" {
  name      = "ubuntu-dev-vm"
  node_name = "pve"
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
    mapping = "dev-projects"
    cache = "always"
    direct_io = true
    expose_acl = true
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
      ssh root@${self.ipv4_addresses[1][0]} "qm stop ${self.vm_id}"
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