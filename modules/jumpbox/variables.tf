variable "ipv4_address" {
  description = "Name of the ipv4 address to assign to the dev vm. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "ipv6_address" {
  description = "Name of the ipv6 address to assign to the dev vm. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "ipv4_gateway" {
  description = "Name of the ipv4 gateway to assign to the dev vm."
  type        = string
  sensitive   = false
}

variable "ipv6_gateway" {
  description = "Name of the ipv6 jumpbox to assign to the dev vm."
  type        = string
  sensitive   = false
}

variable "hostname" {
  description = "Hostname of the container jumpbox"
  type        = string
  sensitive   = false
}

variable "ipv4_proxmox" {
  description = "IPv4 of the proxmox servver"
  type        = string
  sensitive   = false
}

variable node_name {
  description = "Host name of the proxmox server where this module will be deployed"
  type        = string
  sensitive   = false
}

variable "jumpbox_id" {
  description = "ID to be associated to the container. Needed for hookfile"
  type        = number
  sensitive   = false
}

variable "tailscale_auth_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}

variable "ipv4_dns" {
  description = "IP of the DNS server to be used"
  type        = string
  sensitive   = false
}
