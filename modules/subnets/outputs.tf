output "public_subnet_ocid" {
  value = oci_core_subnet.subnet_public.id
}
# output "private_subnet_ocid" {
#   value = oci_core_subnet.subnet_private.id
# }
output "database_subnet_ocid" {
  value = oci_core_subnet.subnet_database.id
}