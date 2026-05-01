#--- Dev VM Variables
dev_vm_ubuntu_base_img_addr = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
dev_vm_net_bridge_interface = "vmbr0"
dev_vm_user_uid             = 200
#--- OMV Variables
omv_debian_base_img_addr = "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-generic-amd64-daily.qcow2"
omv_net_bridge_interface = "vmbr0"
omv_user_uid             = 1000
#--- Openclaw VM Variables
openclaw_net_bridge_interface = "vmbr0"
openclaw_user_uid             = 3000

#--- K3s Controller Variables
k3s_controller_ubuntu_base_img_addr = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
k3s_controller_net_bridge_interface = "vmbr0"
k3s_controller_user_uid             = 1000

#--- K3s GPU Worker Variables
k3s_gpu_worker_ipv4_address = "10.0.100.71/16"
k3s_gpu_worker_ipv6_address = "fde5:e93f:2f0c::100:71/64"
gpu_name                    = "rtx3060"
gpu_pci_id                  = "0000:01:00.0"
gpu_device_id               = "10de:2520"
gpu_iommu_group             = "18"
gpu_subsystem_id            = "1028:0a5d"

#--- Jumpbox Config
jumpbox_id = 2000
