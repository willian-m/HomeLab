# ------------------------------------------------------------------------------
# We will create the users to have granular control on data access

resource "null_resource" "create_users" {
  provisioner "local-exec" {
    command = <<-EOT
      ssh root@${var.proxmox_host} bash << 'ENDSSH'

        # --- Create user for dev image
        current_uid=$(id -u ${var.dev_username})
        if [[ $current_uid != ${var.dev_user_uid} ]]; then
          adduser --system --no-create-home --uid ${var.dev_user_uid} ${var.dev_username}
        fi

        # --- Create user for immich VM/container image
        current_uid=$(id -u immich)
        if [[ $current_uid != ${var.immich_user_uid} ]]; then
          adduser --system --no-create-home --uid ${var.immich_user_uid} immich
        fi

        # --- Create user for jupyter VM/container image
        current_uid=$(id -u jupyter)
        if [[ $current_uid != ${var.jupyter_user_uid} ]]; then
          adduser --system --no-create-home --uid ${var.jupyter_user_uid} jupyter
        fi
      ENDSSH
    EOT
  }
}