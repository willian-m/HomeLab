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
  endpoint = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure = false

  ssh {
    agent = true
    username = "root"
  }
}