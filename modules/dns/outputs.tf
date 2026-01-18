output "adguard_oci_image_id" {
  description = "The OCI image ID for AdGuard Home"
  value       = proxmox_virtual_environment_oci_image.adguard_img.id
}

output "adguard_oci_image_file" {
  description = "The OCI image file name for AdGuard Home"
  value       = proxmox_virtual_environment_oci_image.adguard_img.file_name
}