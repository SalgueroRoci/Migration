output "file_system_id" {
    value = oci_file_storage_file_system.TFfile_system.id
} 
data "oci_core_private_ip" "private_ip" {
    private_ip_id = oci_file_storage_mount_target.TFmount_target_public.private_ip_ids[0]
}
output "private_ip" {
    value = data.oci_core_private_ip.private_ip.ip_address
}