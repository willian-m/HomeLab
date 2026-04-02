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

variable "ipv4_k3s_gpu" {
  description = "IPv4 of the K3s gpu node"
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

variable "ipv4_dns" {
  description = "IP number of the primary dns to be used"
  type = string
  sensitive = false
}

variable "ipv4_gateway" {
  description = "IP number of the gateway (i.e., your router)"
  type = string
  sensitive = false
}

variable "CUPSADMIN_ENCRYPTED" {
  description = "Encrypted admin username for cups"
  type = string
  sensitive = true
}

variable "CUPSPASSWORD_ENCRYPTED" {
  description = "Encrypted cups password"
  type = string
  sensitive = true
}
