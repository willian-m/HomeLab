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

variable "tailnet_dns_name" {
  description = "Tailnet DNS name"
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

variable "omv_storage_host_path" {
  description = "Path on the Proxmox host to be shared with OMV via VirtioFS"
  type        = string
  sensitive   = false
}

variable "nfs_clients" {
  description = "IP address in CIDR notation of the clients that should be allowed to access the share"
  type = string
  sensitive = false
}

#*******************************************************************************
# K3s Controller Variables
#*******************************************************************************

variable "k3s_controller_net_bridge_interface" {
  description = "Name of the network interface which will be used as a bridge for k3s controller"
  type        = string
  sensitive   = false
}

variable "k3s_controller_username" {
  description = "Username used to access the created k3s controller"
  type        = string
  sensitive   = false
}

variable "k3s_controller_password" {
  description = "Hashed password that will be used to escalate privileges on the k3s controller"
  type        = string
  sensitive   = true
}

variable "k3s_controller_user_uid" {
  description = "UID to be assigned to k3s controller user"
  type        = number
  sensitive   = false
}

variable "k3s_controller_ubuntu_base_img_addr" {
  description = "Address from where to download the Ubuntu base image"
  type        = string
  sensitive   = false
}

variable "k3s_controller_ipv4_address" {
  description = "Name of the ipv4 address to assign to the k3s controller. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "k3s_controller_ipv6_address" {
  description = "Name of the ipv6 address to assign to the k3s controller. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "k3s_token" {
  description = "Token used to register work nodes into k3s"
  type = string
  sensitive = true
}

#*******************************************************************************
# K3s GPU Worker Variables
#*******************************************************************************


variable "gpu_name" {
  description = "Name of the GPU to pass through"
  type        = string
  sensitive   = false
}

variable "gpu_device_id" {
  description = "Device ID of the GPU to pass through (e.g. 10de:2520)"
  type        = string
  sensitive   = false
  default     = "10de:2520"
}

variable "gpu_pci_id" {
  description = "PCI ID of the GPU to pass through (e.g. 0000:01:00.0)"
  type        = string
  sensitive   = false
  default     = "0000:01:00.0"
}

variable "gpu_iommu_group" {
  description = "IOMMU group of the GPU to pass through"
  type        = string
  sensitive   = false
}

variable "gpu_subsystem_id" {
  description = "Subsystem ID of the GPU to pass through"
  type        = string
  sensitive   = false
}

variable "k3s_gpu_worker_ipv4_address" {
  description = "Name of the ipv4 address to assign to the k3s worker. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "k3s_gpu_worker_ipv6_address" {
  description = "Name of the ipv6 address to assign to the k3s worker. Includes CIDR notation."
  type        = string
  sensitive   = false
}

#*******************************************************************************
# Jumpbox
#*******************************************************************************

variable "jumpbox_hostname" {
  description = "Hostname to be given to the jumpbox container"
  type        = string
  sensitive   = false
}

variable "proxmox_ip" {
  description = "IP of proxmox host"
  type        = string
  sensitive   = false
}

variable "ipv4_jumpbox" {
  description = "IPv4 address to assign to the jumpbox. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "ipv6_jumpbox" {
  description = "IPv6 address to assign to the jumpbox. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "jumpbox_id" {
  description = "ID to be associated to the jumpbox"
  type = number
  sensitive = false
}

variable "proxmox_root_password" {
  description = "Enter proxmox's password"
  type = string
  sensitive = true
}

#*******************************************************************************
# Openclaw VM Variables
#*******************************************************************************

variable "openclaw_net_bridge_interface" {
  description = "Name of the network interface which will be used as a bridge for openclaw VM"
  type        = string
  sensitive   = false
}

variable "openclaw_user_uid" {
  description = "UID to be assigned to openclaw VM user"
  type        = number
  sensitive   = false
}
variable "openclaw_vm_password" {
  description = "Hashed password that will be used to escalate privileges on the VM. Generate it with `mkpasswd --method=SHA-512 --rounds=500000`"
  type        = string
  sensitive   = true
}

variable "openclaw_ipv4_address" {
  description = "Name of the ipv4 address to assign to the openclaw. Includes CIDR notation."
  type        = string
  sensitive   = false
}

variable "openclaw_ipv6_address" {
  description = "Name of the ipv6 address to assign to the openclaw vm. Includes CIDR notation."
  type        = string
  sensitive   = false
}

#*******************************************************************************
# CUPS variable
#*******************************************************************************

##### Install the SealedSecret CRD and server-side controller into the kube-system namespace:
# kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.36.1/controller.yaml

##### Install the client side
# curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.36.1/kubeseal-0.36.1-linux-amd64.tar.gz"
# tar -xvzf kubeseal-0.36.1-linux-amd64.tar.gz kubeseal
# sudo install -m 755 kubeseal /usr/local/bin/kubeseal

##### Generate secrets with
# kubectl create secret generic cups-credentials \
# --from-literal=CUPSADMIN=<username> \
# --from-literal=CUPSPASSWORD=<password> \
# --dry-run=client -o yaml | kubeseal -o yaml --namespace cups > k8s/cups/sealed-secret.yaml

variable "CUPSADMIN_ENCRYPTED" {
  description = "Encrypted username for cups"
  type = string
  sensitive = true
}

variable "CUPSPASSWORD_ENCRYPTED" {
  description = "Encrypted cups password"
  type = string
  sensitive = true
}
