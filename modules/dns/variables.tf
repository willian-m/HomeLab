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
  description = "Name of the ipv6 gateway to assign to the dev vm."
  type        = string
  sensitive   = false
}

variable "node_name" {
  description = "Name of the node where to deploy the VM"
  type        = string
  sensitive   = false
}