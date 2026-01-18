
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_oci_image" "adguard_img" {
  node_name    = "pve"
  datastore_id = "local"
  reference    = "docker.io/adguard/adguardhome:latest"
  file_name    = "adguardhome-latest.tar"
  overwrite    = true
}


resource "proxmox_virtual_environment_container" "adguard_container" {
  node_name       = "pve"
  tags            = ["dns", "terraform"]

  unprivileged = true
  features {
    nesting = false
  }
  
  operating_system {
    template_file_id = proxmox_virtual_environment_oci_image.adguard_img.id
  }

  initialization {
    hostname = "adguard-home"
    ip_config {
      ipv4 {
        address = "192.168.0.200/24"
        gateway = "192.168.0.1"
      }
    }
  }

  network_interface {
    name = "veth0"
    bridge = "vmbr0"
  }


  disk {
    datastore_id = "local-lvm"
    size    = 1
  }

  # volume mounts
  mount_point {
    volume = "ExternalHardDrive"
    size   = "10G"
    path   = "/opt/adguardhome/work"
    backup = true
  }

  mount_point {
    volume = "ExternalHardDrive"
    size   = "10G"
    path   = "/opt/adguardhome/conf"
    backup = true
  }

  startup {
    order      = "1"
    up_delay   = "15"
    down_delay = "60"
  }

  start_on_boot = true

}