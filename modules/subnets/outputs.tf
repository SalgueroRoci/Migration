output "public_subnet_ocid" {
  value = oci_core_subnet.subnet_public.id
}
# output "private_subnet_ocid" {
#   value = oci_core_subnet.subnet_private.id
# }
output "database_subnet_ocid" {
  value = oci_core_subnet.subnet_database.id
}

output "network_security_group_ocid" {
  value = oci_core_network_security_group.TFnetwork_security_group.id
}