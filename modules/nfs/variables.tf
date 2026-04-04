variable "proxmox_host" {
  description = "Name of the proxmox node which we will deploy"
  type = string
  sensitive = false
}

variable "proxmox_ip" {
  description = "IP of the proxmox node which we will deploy"
  type = string
  sensitive = false
}

variable "proxmox_username" {
  description = "Username that will be used to log in into proxmox node"
  type = string
  sensitive = false
}

variable "k3s_controller_ip" {
  description = "IP of the k3s controller"
  type = string
  sensitive = false
}

variable "k3s_gpu_node_ip" {
  description = "IP of the k3s gpu worker node"
  type = string
  sensitive = false
}

