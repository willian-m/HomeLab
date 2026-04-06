
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

variable "ipv4_address" {
  description = "Name of the ipv4 address to assign to the AdGuard Home container. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "ipv6_address" {
  description = "Name of the ipv6 address to assign to the AdGuard Home container. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "ipv4_gateway" {
  description = "Name of the ipv4 gateway to assign to the AdGuard Home container."
  type        = string
  sensitive   = false
}

variable "ipv6_gateway" {
  description = "Name of the ipv6 gateway to assign to the AdGuard Home container."
  type        = string
  sensitive   = false
}

variable "node_name" {
  description = "Name of the node where to deploy the VM"
  type        = string
  sensitive   = false
}

variable "dns_server_ip" {
  description = "IP address of the DNS server to be used by the VM"
  type        = string
  sensitive   = false
}

variable "nfs_server_ip" {
  description = "IP address of the NFS server (OMV)"
  type        = string
  sensitive   = false
}

variable "k3s_token" {
  description = "Token used to register work nodes"
  type        = string
  sensitive   = true
}
