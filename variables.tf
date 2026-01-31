#*******************************************************************************
# Variables used to access Proxmox and create VMs
#*******************************************************************************
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

variable "private_key_path" {
  description = "Path to the private key used to access proxmox server via SSH"
  type        = string
  sensitive   = false
}

variable "node_name" {
  description = "Name of the node where to deploy the VMs and containers"
  type        = string
  sensitive   = false
}

#*******************************************************************************
# Variables used across multiple modules
#*******************************************************************************

variable "public_key_path" {
  description = "Path to the public key used to access VMs via SSH"
  type        = string
  sensitive   = false
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key used to authenticate the VM into the Tailscale network"
  type        = string
  sensitive   = true
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

variable "dns_ipv4_address" {
  description = "Name of the ipv4 address to assign to the AdGuard Home container. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "dns_ipv6_address" {
  description = "Name of the ipv6 address to assign to the AdGuard Home container. Includes CIDR notation."
  type        = string
  sensitive   = false
}

#*******************************************************************************
# DEV VM Variables
#*******************************************************************************

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

variable "dev_vm_ipv4_address" {
  description = "Name of the ipv4 address to assign to the dev vm. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "dev_vm_ipv6_address" {
  description = "Name of the ipv6 address to assign to the dev vm. Includes CIDR notation."
  type        = string
  sensitive   = false
}

#*******************************************************************************
# OpenMediaVault VMs Variables
#*******************************************************************************

variable "omv_net_bridge_interface" {
  description = "Name of the network interface which will be used as a bridge for dev VM"
  type        = string
  sensitive   = false
}

variable "omv_username" {
  description = "Username used to access the created dev VM"
  type        = string
  sensitive   = false
}

variable "omv_password" {
  description = "Hashed password that will be used to escalate privileges on the dev VM. Generate it with `mkpasswd --method=SHA-512 --rounds=500000`"
  type        = string
  sensitive   = true
}

variable "omv_user_uid" {
  description = "UID to be assigned to dev VM user"
  type        = number
  sensitive   = false
}

variable "omv_debian_base_img_addr" {
  description = "Address from where to download the base image of the dev VM"
  type        = string
  sensitive   = false
}

variable "omv_ipv4_address" {
  description = "Name of the ipv4 address to assign to the dev vm. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "omv_ipv6_address" {
  description = "Name of the ipv6 address to assign to the dev vm. Includes CIDR notation."
  type        = string
  sensitive   = false
}