variable compartment_ocid {}
variable bucket_name {}
variable bucket_access_type {}   
variable bucket_storage_tier {}

data "oci_objectstorage_namespace" "TFnamespace" {
    compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "TFbucket" {
    #Required
    compartment_id = var.compartment_ocid
    name = var.bucket_name
    namespace = data.oci_objectstorage_namespace.TFnamespace.namespace

    #Optional
    access_type = var.bucket_access_type    
    storage_tier = var.bucket_storage_tier
}