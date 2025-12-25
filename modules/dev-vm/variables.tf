
variable "net_bridge_interface" {
  description = "Name of the network interface which will be used as a bridge"
  type        = string
  sensitive   = false
}

variable "username" {
  description = "Username used to access the created image"
  type        = string
  sensitive   = false
}

variable "user_uid" {
  description = "UID to be assigned to VM user"
  type        = number
  sensitive   = false
}

variable "vm_password" {
  description = "Hashed password that will be used to escalate privileges on the VM. Generate it with `mkpasswd --method=SHA-512 --rounds=500000`"
  type        = string
  sensitive   = true
}

variable "ubuntu_base_img_addr" {
  description = "Address from where to download the base image of the VM"
  type        = string
  sensitive   = false
}

variable "public_key_path" {
  description = "Path to the public key used to log in the created VMs"
  type        = string
  sensitive   = false
}

variable "proxmox_host" {
  description = "Proxmox hostname (for ssh access)"
  type        = string
  sensitive   = false
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key used to authenticate the VM into the Tailscale network"
  type        = string
  sensitive   = true
}