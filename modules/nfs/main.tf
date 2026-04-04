terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

# resource "null_resource" "create_user_infrastructure" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       ssh root@${var.proxmox_host} bash << 'ENDSSH'

#         # --- Create user for dev image
#         current_uid=$(id -u ${var.username})
#         if [[ $current_uid != ${var.user_uid} ]]; then
#           adduser --system --no-create-home --uid ${var.user_uid} ${var.username}
#         fi
#         mkdir -p ${var.storage_host_path}
#         chown ${var.username}:nogroup ${var.storage_host_path}
#       ENDSSH
#     EOT
#   }
# }

resource "local_file" "ansible_inventory_nfs" {
  content = templatefile("${path.module}/inventory.tftpl", {
    proxmox_node = var.proxmox_host
    host_ip  = var.proxmox_ip
    username = var.proxmox_username
  })

  filename = "${path.module}/../../ansible/inventory/nfs.yml"
}

resource "local_file" "ansible_playbook_nfs" {
  content = templatefile("${path.module}/playbook.tftpl", {
    k3s_controller_ip = split("/",var.k3s_controller_ip)[0]
    k3s_gpu_node_ip   = split("/",var.k3s_gpu_node_ip)[0]
  })

  filename = "${path.module}/../../ansible/playbooks/nfs.yml"
}

resource "null_resource" "ansible_provision_omv" {
  depends_on = [
    local_file.ansible_inventory_nfs,
    local_file.ansible_playbook_nfs
  ]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i ${local_file.ansible_inventory_nfs.filename} ${local_file.ansible_playbook_nfs.filename} \
      --ssh-extra-args='-o StrictHostKeyChecking=no'
    EOT
  }
}
