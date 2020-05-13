// Copyright (c) 2017, 2019, 2020 Oracle and/or its affiliates. All rights reserved.

variable tenancy_ocid {}
variable compartment_name {}
variable description {}
variable enable_delete {}

resource "oci_identity_compartment" "TFcompartment" {
  name           = var.compartment_name
  description    = var.description
  compartment_id = var.tenancy_ocid
  enable_delete  = var.enable_delete  // true will cause this compartment to be deleted when running `terrafrom destroy`
}
