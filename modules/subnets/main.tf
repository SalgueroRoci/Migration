variable compartment_ocid {} 
variable vcn_ocid {}
variable default_dhcp_ocid {}
variable rt_private {}
variable rt_public {}

# prefix for all the resources
variable prefix {} 
# variable private_subnet_cidr_block {}
variable public_subnet_cidr_block {}
variable db_subnet_cidr_block {} 
variable vcn_cidr_block {}

# Note: Not necessary because of script server. 
# resource "oci_core_subnet" "subnet_private" {
#   display_name        = "${var.prefix}-subnet-private"
#   cidr_block          = var.private_subnet_cidr_block
#   compartment_id      = var.compartment_ocid
#   vcn_id              = var.vcn_ocid

#   route_table_id      = var.rt_private
#   security_list_ids   = [oci_core_security_list.private_security_list.id]
#   dhcp_options_id     = var.default_dhcp_ocid 
#   prohibit_public_ip_on_vnic = true
# }

resource "oci_core_subnet" "subnet_database" {
  display_name        = "${var.prefix}-subnet-database"
  cidr_block          = var.db_subnet_cidr_block
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_ocid

  route_table_id      = var.rt_private
  security_list_ids   = [oci_core_security_list.private_security_list.id]
  dhcp_options_id     = var.default_dhcp_ocid 
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "subnet_public" {
  display_name        = "${var.prefix}-subnet-public"
  cidr_block          = var.public_subnet_cidr_block
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_ocid

  route_table_id      = var.rt_public
  security_list_ids   = [oci_core_security_list.public_security_list.id]
  dhcp_options_id     = var.default_dhcp_ocid 
  prohibit_public_ip_on_vnic = false
}