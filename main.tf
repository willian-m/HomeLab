# --- INSTRUCTIONS ---
# 1. Do not forget to set up access token secrets.tfvars.
# 2. Add your public key to the proxmox server since some steps require ssh.
# 3. Make sure you have a ssh-agent running and have the key loaded on 
# 4. If having trouble authenticating due to certificates, set `insecure = false` below
# 5. Initial password for dev machine is dev_vm_env
# --------------------

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.69.0"
    }
  }
}

# --- Configure access of terraform to proxmox
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
  # alias = "proxmox"

  ssh {
    agent    = true
    username = "root"
  }
}

resource "null_resource" "start_ssh_agent" {
  provisioner "local-exec" {
    command = <<-EOF
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)"
        ssh-add ${var.private_key_path} 2>/dev/null
      fi
    EOF
  }
}

module "dev_vm" {
  source = "./modules/dev-vm"

  node_name            = var.node_name
  username             = var.dev_vm_username
  user_uid             = var.dev_vm_user_uid
  ubuntu_base_img_addr = var.dev_vm_ubuntu_base_img_addr
  vm_password          = var.dev_vm_password
  public_key_path      = var.public_key_path
  net_bridge_interface = var.dev_vm_net_bridge_interface
  proxmox_host         = var.proxmox_host
  tailscale_auth_key   = var.tailscale_auth_key

  ipv4_address         = var.dev_vm_ipv4_address
  ipv6_address         = var.dev_vm_ipv6_address
  ipv4_gateway         = var.ipv4_gateway
  ipv6_gateway         = var.ipv6_gateway
}

module "dns" {
  source = "./modules/dns"

  node_name           = var.node_name

  ipv4_address        = var.dns_ipv4_address
  ipv6_address        = var.dns_ipv6_address
  ipv4_gateway        = var.ipv4_gateway
  ipv6_gateway        = var.ipv6_gateway
}

module "omv" {
  source = "./modules/omv"

  node_name            = var.node_name
  username             = var.omv_username
  user_uid             = var.omv_user_uid
  debian_base_img_addr = var.omv_debian_base_img_addr
  vm_password          = var.omv_password
  public_key_path      = var.public_key_path
  net_bridge_interface = var.omv_net_bridge_interface
  proxmox_host         = var.proxmox_host
  tailscale_auth_key   = var.tailscale_auth_key

  ipv4_address         = var.omv_ipv4_address
  ipv6_address         = var.omv_ipv6_address
  ipv4_gateway         = var.ipv4_gateway
  ipv6_gateway         = var.ipv6_gateway

  dns_server_ip     = var.dns_ipv4_address
  storage_host_path = var.omv_storage_host_path

}
