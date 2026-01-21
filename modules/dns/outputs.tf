output "adguard_oci_image_id" {
  description = "The OCI image ID for AdGuard Home"
  value       = proxmox_virtual_environment_oci_image.adguard_img.id
}

output "adguard_oci_image_file" {
  description = "The OCI image file name for AdGuard Home"
  value       = proxmox_virtual_environment_oci_image.adguard_img.file_name
}

output "adguard_network_ip" {
  description = "The IP address assigned to the AdGuard Home container"
  value       = proxmox_virtual_environment_container.adguard_container.initialization[0].ip_config[0].ipv4[0].address

}