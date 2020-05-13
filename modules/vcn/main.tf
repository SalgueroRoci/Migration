variable compartment_ocid {} 
variable region {}

# prefix for all the resources
variable prefix {}
variable vcn_cidr_block {} 

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}_VCN"
  dns_label      = "${var.prefix}VCN"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}-ig"
  vcn_id         = oci_core_vcn.vcn.id
}

data "oci_core_services" "oci_services" {
} 

resource "oci_core_service_gateway" "service_gateway" {
    #Required
    compartment_id = var.compartment_ocid
    display_name = "${var.prefix}-sg"
    vcn_id = oci_core_vcn.vcn.id
    services {
        #All OCI Services use 0, Object Storage use 1
        service_id = data.oci_core_services.oci_services.services.1.id
    }
}

resource "oci_core_nat_gateway" "nat_gateway" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn.id
    display_name = "${var.prefix}-nat"
}

resource "oci_core_route_table" "rt_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}-rt-public"

  route_rules {
    destination        = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_route_table" "rt_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}-rt-private"

# Use oci_services.services[0] for ObjStorage or use oci_services.services[1] for all services
  route_rules {
        destination       = data.oci_core_services.oci_services.services[1].cidr_block
        network_entity_id = oci_core_service_gateway.service_gateway.id 
        destination_type  = "SERVICE_CIDR_BLOCK"
  }
  route_rules {
        destination       = "0.0.0.0/0"
        network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}
