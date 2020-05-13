
variable compartment_ocid {} 
variable availability_domain {}  
variable file_system_display_name {}
variable tenancy_ocid {}

variable public_subnet_ocid {}
variable public_mount_target_display_name {}
variable public_export_path {}

# variable private_subnet_ocid {}
# variable private_mount_target_display_name {}
# variable private_export_path {}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_file_storage_file_system" "TFfile_system" {
    #Required
    availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain],"name")
    compartment_id = var.compartment_ocid
    display_name = var.file_system_display_name
}

resource "oci_file_storage_mount_target" "TFmount_target_public" {
    #Required
    availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain],"name")
    compartment_id = var.compartment_ocid
    subnet_id = var.public_subnet_ocid
    display_name = var.public_mount_target_display_name
}

resource "oci_file_storage_export_set" "TFexport_set_public" {
    #Required
    mount_target_id = oci_file_storage_mount_target.TFmount_target_public.id
}

resource "oci_file_storage_export" "TFexport_public" {
    #Required
    export_set_id = oci_file_storage_export_set.TFexport_set_public.id
    file_system_id = oci_file_storage_file_system.TFfile_system.id
    path = var.public_export_path 
}

///==== File system for private
# resource "oci_file_storage_mount_target" "TFmount_target_private" {
#     #Required
#     availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain],"name")
#     compartment_id = var.compartment_ocid
#     subnet_id = var.private_subnet_ocid
#     display_name = var.private_mount_target_display_name
# }

# resource "oci_file_storage_export_set" "TFexport_set_private" {
#     #Required
#     mount_target_id = oci_file_storage_mount_target.TFmount_target_private.id
# }

# resource "oci_file_storage_export" "TFexport_private" {
#     #Required
#     export_set_id = oci_file_storage_export_set.TFexport_set_private.id
#     file_system_id = oci_file_storage_file_system.TFfile_system.id
#     path = var.private_export_path
# }

