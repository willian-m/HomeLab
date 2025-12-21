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

# variable "proxmox_user" {
#   description = "User for accessing proxmox"
#   type        = string
#   sensitive   = true
# }

variable "proxmox_api_token" {
  description = "API Token used for accessing proxmox"
  type        = string
  sensitive   = true
}

variable "pve_storage" {
  description = "Choose where templates and VMs will be stored"
  type        = string
  sensitive   = false
}

variable "ubuntu_base_img_addr" {
  description = "Address from where to download the base image"
  type        = string
  sensitive   = false
}

variable "template_name" {
  description = "Name of the template we will be creating"
  type        = string
  sensitive   = false
}

variable "net_bridge_interface" {
  description = "Name of the network interface which will be used as a bridge"
  type        = string
  sensitive   = false
}

variable "dev_username" {
  description = "Username used to access the created images"
  type        = string
  sensitive   = false
}

variable "dev_user_uid" {
  description = "UID to be assigned to user"
  type        = number
  sensitive   = false
}

variable "immich_user_uid" {
  description = "UID to be assigned to immich user"
  type        = number
  sensitive   = false
}

variable "jupyter_user_uid" {
  description = "UID to be assigned to jupyter user"
  type        = number
  sensitive   = false
}

variable "dev_vm_password"{
  description = "Hashed password that will be used to escalate privileges on the VM. Generate it with `mkpasswd --method=SHA-512 --rounds=500000`"
  type        = string
  sensitive   = true
}

variable "public_key_path"{
  description = "Path to the public key used to log in the created VMs"
  type        = string
  sensitive   = false
}
