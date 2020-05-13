# Output variables from created compute instance
output "compartment_ocid" {
  value = oci_identity_compartment.TFcompartment.id
}
