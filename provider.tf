
/*
 * This example file shows how to configure the oci provider to target the a single region.
 */

// These variables would commonly be defined as environment variables or sourced in a .env file
terraform {
  required_version = ">= 0.12.0"
}

provider "oci" {
  version          = ">= 3.5.0"
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid

  //Following not needed if using Resource Manager
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
