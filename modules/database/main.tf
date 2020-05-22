variable availability_domain {} 
variable compartment_ocid {}
variable tenancy_ocid {}
variable fault_domain {
    default = "1"
}

variable subnet_ocid {}
variable db_display_name {} 
variable db_hostname {}
variable db_shape {}
variable db_node_count {} 
variable db_ssh_public_keys {}
variable db_data_storage_size_in_gb {} 

variable db_home_admin_password {}
variable db_home_display_name {}
variable db_home_name {}
variable db_pdb_name {}
variable db_version {}
variable db_edition {}

variable db_backup_anabled {
    default = false
}
variable db_backup_recovery_window {
    default = "7"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_database_db_system" "TFDatabaseSystem" {
    #Required
    availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain],"name")
    compartment_id = var.compartment_ocid
    fault_domains = ["FAULT-DOMAIN-${var.fault_domain}"]
    
    subnet_id = var.subnet_ocid
    display_name = var.db_display_name 
    hostname = var.db_hostname
    shape = var.db_shape
    node_count = var.db_node_count 
    ssh_public_keys = var.db_ssh_public_keys
    data_storage_size_in_gb = var.db_data_storage_size_in_gb 
    
    domain = var.db_hostname
    database_edition = var.db_edition
    license_model = "LICENSE_INCLUDED"
    time_zone = "UTC"

    db_home {
        
        #Optional
        #Refer to the top on which database version you need
        db_version = var.db_version
        display_name = var.db_home_display_name
        
        #Required
        database {
            #Required
            admin_password = var.db_home_admin_password

            db_name = var.db_home_name 
            pdb_name = var.db_pdb_name
            
            db_backup_config {
                #Optional
                auto_backup_enabled = var.db_backup_anabled  
                recovery_window_in_days = var.db_backup_recovery_window
            }
        }

    }
    
}