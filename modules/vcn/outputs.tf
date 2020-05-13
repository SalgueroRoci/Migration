output "vcn_ocid" {
  value = oci_core_vcn.vcn.id
}
output "public_rt_ocid" {
  value = oci_core_route_table.rt_public.id
}
output "private_rt_ocid" {
  value = oci_core_route_table.rt_private.id
}
output "service_gateway_route" {
  value = "${data.oci_core_services.oci_services.services.1.description}"
}
output "default_dhcp_ocid" {
  value = oci_core_vcn.vcn.default_dhcp_options_id
}
