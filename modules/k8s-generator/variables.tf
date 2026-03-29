variable "allocated_registry_storage" {
    description = "Space to be allocated for the image registry"
    type        = number
    sensitive   = false
}

variable "registry_node_port" {
    description = "Port number of the registry to be exposed outside the cluster"
    type        = number
    sensitive   = false
}

variable "ipv4_k3s_controller" {
  description = "IPv4 of the K3s controller"
  type = string
  sensitive = false
}

variable "username" {
  description = "Username to login on K3s controller"
  type = string
  sensitive = false
}

variable "tailnet_dns_name" {
  description = "Tailnet DNS name"
  type = string
  sensitive = false
}

variable "jumpbox_hostname" {
  description = "Hostname of the jumpbox"
  type = string
  sensitive = false
}