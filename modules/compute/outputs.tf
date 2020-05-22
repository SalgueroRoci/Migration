# Output variables from created compute instance
output "instance_name" {
  value = oci_core_instance.TFInstance.display_name
}
output "instance_ocid" {
  value = oci_core_instance.TFInstance.id
}
output "public_ip" {
  value = oci_core_instance.TFInstance.public_ip
}
output "private_ip" {
  value = oci_core_instance.TFInstance.private_ip
}
output "boot_volume_id" {
  value = oci_core_instance.TFInstance.boot_volume_id
}
