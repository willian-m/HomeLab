# --- Declare secret variables to be used by terraform
variable "proxmox_host" {
  description = "Proxmox hostname (for ssh access)"
  type        = string
  sensitive   = false
}

variable "proxmox_endpoint" {
  description = "Address to access proxmox endpoint (token access)"
  type        = string
  sensitive   = false
}

variable "proxmox_api_token" {
  description = "API Token used for accessing proxmox"
  type        = string
  sensitive   = true
}

variable "public_key_path" {
  description = "Path to the public key used to access VMs via SSH"
  type        = string
  sensitive   = false
}

variable "dev_vm_net_bridge_interface" {
  description = "Name of the network interface which will be used as a bridge for dev VM"
  type        = string
  sensitive   = false
}

variable "dev_vm_username" {
  description = "Username used to access the created dev VM"
  type        = string
  sensitive   = false
}

variable "dev_vm_password" {
  description = "Hashed password that will be used to escalate privileges on the dev VM. Generate it with `mkpasswd --method=SHA-512 --rounds=500000`"
  type        = string
  sensitive   = true
}

variable "dev_vm_user_uid" {
  description = "UID to be assigned to dev VM user"
  type        = number
  sensitive   = false
}

variable "dev_vm_ubuntu_base_img_addr" {
  description = "Address from where to download the base image of the dev VM"
  type        = string
  sensitive   = false
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key used to authenticate the VM into the Tailscale network"
  type        = string
  sensitive   = true
}
