variable tenancy_ocid {}
variable compartment_ocid {
  description = "Add an existing compartment OCID"
}
variable availability_domain {
  description = "Starting index 0. Use '0' for Availibility Domain 1" 
}
variable root_compartment_ocid {} 
variable region {}
variable ssh_public_key {
  description = "Seperate ssh public keys by ',' to add multiple. ex: <Public_key>,<Public_Key>"
} 

variable prefix {
  description = "Prefix for all the resources."
}

variable vcn_cidr {
  description = "CIDR block for VCN example: 10.0.0.0/16"
}
variable public_subnet_cidr {}
variable db_subnet_cidr {}

variable db_size {
  description = "Database size must be in gb: 256, 512, 1024, 2048, 4096 GB"
}
variable edq_size {
  description = "Storage size in GB. Minimum 50 GB"
}
variable sftp_size {
  description = "Storage size in GB. Minimum 50 GB"
}
variable bastion_size {
  description = "Storage size in GB. Minimum 50 GB"
}

variable db_shape {
  description = "Example: VM.Standard2.1, VM.Standard2.2"
}
variable edq_shape {
  description = "Example: VM.Standard2.1, VM.Standard2.2"
}
variable sftp_shape {
  description = "Example: VM.Standard2.1, VM.Standard2.2"
}
variable bastion_shape {
  description = "Example: VM.Standard2.1, VM.Standard2.2"
}

variable db_edition {
  description = "Database edition: STANDARD_EDITION, ENTERPRISE_EDITION, ENTERPRISE_EDITION_EXTREME_PERFORMANCE, or ENTERPRISE_EDITION_EXTREME_PERFORMANCE."
  default = "STANDARD_EDITION"
}
variable db_version {
  description = "Versions available 11.2.0.4, 12.1.0.2, 12.2.0.1, 18.0.0.0, 19.0.0.0"
  default = "12.2.0.1"
}
variable db_hostname {
  description = "Cannot be longer than 8 characters. Starts with a letter."
}
variable db_main_name {
  description = "Cannot be longer than 8 characters. Starts with a letter."
}
variable db_pdb_name {
  description = "Cannot be longer than 8 characters. Starts with a letter."
}
variable db_admin_password {
  description = "Must be longer than 12 characters. Passwords can contain only alphanumeric characters and the underscore (_), dollar sign ($), and pound sign (#). Requires 2 uppercase, 2 lowercase, 2 symbols, and 2 numbers."
}

variable fs_mount_path_folder {
  description = "Path Folder for FSS mount. Required: Add '/' infront."
}

//Following not needed if using Resource Manager
variable private_key_path {} 
variable fingerprint {}
variable ssh_private_key_path {}
variable user_ocid {}

