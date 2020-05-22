
resource "oci_core_network_security_group" "TFnetwork_security_group" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = var.vcn_ocid

    display_name = "${var.prefix}-NSG" 
}

resource "oci_core_network_security_group_security_rule" "TF_NSG_https_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.TFnetwork_security_group.id
    direction = "INGRESS"
    protocol = local.tcp_protocol

    #Optional
    description = "HTTPS for EDQ server" 
    source = local.anywhere
    source_type = "CIDR_BLOCK"
    stateless = "false"
    tcp_options { 
        # allow edq https port 443
        destination_port_range {
            #Required
            max = local.https_port
            min = local.https_port
        } 
    }
}

resource "oci_core_network_security_group_security_rule" "TF_NSG_EDQ_sftp_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.TFnetwork_security_group.id
    direction = "INGRESS"
    protocol = local.tcp_protocol

    #Optional
    description = "Port for EDQ's sftp server" 
    source = local.anywhere
    source_type = "CIDR_BLOCK"
    stateless = "false"
    tcp_options { 
        # allow edq sftp port 2222
        destination_port_range {
            #Required
            max = local.edq_port
            min = local.edq_port
        } 
    }
}

resource "oci_core_security_list" "private_security_list" {
  compartment_id    = var.compartment_ocid
  display_name      = "${var.prefix}-seclist-private"
  vcn_id            = var.vcn_ocid 

  egress_security_rules {
    protocol    = local.all_protocols
    destination = local.anywhere
  }

  # allow ssh
  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = var.vcn_cidr_block

    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }
  }

  # allow oracle_db
  ingress_security_rules {
      protocol = local.tcp_protocol
      source   = var.vcn_cidr_block

      tcp_options {
      min = local.oracle_db_port
      max = local.oracle_db_port
      }
  }
  
  //Following ports are for file_storage
  # ingress_security_rules { 
  #   protocol = local.tcp_protocol
  #   source   = local.anywhere

  #   tcp_options {
  #     min = local.FS_port
  #     max = local.FS_port
  #   }
  # }

  # ingress_security_rules { 
  #   protocol = local.tcp_protocol
  #   source   = local.anywhere

  #   tcp_options {
  #     min = local.FS_min
  #     max = local.FS_max
  #   }
  # }

  # ingress_security_rules { 
  #   protocol = local.udp_protocol
  #   source   = local.anywhere

  #   udp_options {
  #     min = local.FS_port
  #     max = local.FS_port
  #   }
  # }

  # ingress_security_rules { 
  #   protocol = local.udp_protocol
  #   source   = local.anywhere

  #   udp_options {
  #     min = local.FS_min
  #     max = local.FS_min
  #   }
  # }
  //===================

  ingress_security_rules {
    protocol  = local.icmp_protocol
    source    = local.anywhere
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }

   // allow inbound icmp traffic of ping
  # ingress_security_rules {
  #   protocol  = local.icmp_protocol
  #   source    = local.anywhere
  #   stateless = true

  #   icmp_options {
  #     type = 0
  #   }
  # }
  # // allow inbound icmp traffic of ping
  # ingress_security_rules {
  #   protocol  = local.icmp_protocol
  #   source    = local.anywhere
  #   stateless = true

  #   icmp_options {
  #     type = 8
  #   }
  # }
  
}


resource "oci_core_security_list" "public_security_list" {
  compartment_id    = var.compartment_ocid
  display_name      = "${var.prefix}-seclist-public"
  vcn_id            = var.vcn_ocid 

  egress_security_rules {
    protocol    = local.all_protocols
    destination = local.anywhere
  }

  # allow ssh
  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }
  }

  #  # allow http
  # ingress_security_rules {
   
  #   protocol = local.tcp_protocol
  #   source   = local.anywhere

  #   tcp_options {
  #     min = local.http_port
  #     max = local.http_port
  #   }
  # }

  # allow https
  # ingress_security_rules {
  #   protocol = local.tcp_protocol
  #   source   = local.anywhere

  #   tcp_options {
  #     min = local.https_port
  #     max = local.https_port
  #   }
  # }

  # allow edq sftp port 2222
  # ingress_security_rules {
  #   protocol = local.tcp_protocol
  #   source   = local.anywhere

  #   tcp_options {
  #     min = local.edq_port
  #     max = local.edq_port
  #   }
  # }

  # allow JMX port for EDQ
  # ingress_security_rules {
  #   # allow ssh
  #   protocol = local.tcp_protocol
  #   source   = local.anywhere

  #   tcp_options {
  #     min = local.JMX_port
  #     max = local.JMX_port
  #   }
  # }

  //Following ports are for file_storage
  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = var.vcn_cidr_block

    tcp_options {
      min = local.FS_port
      max = local.FS_port
    }
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = var.vcn_cidr_block

    tcp_options {
      min = local.FS_min
      max = local.FS_max
    }
  }

  ingress_security_rules { 
    protocol = local.udp_protocol
    source   = var.vcn_cidr_block

    udp_options {
      min = local.FS_port
      max = local.FS_port
    }
  }

  ingress_security_rules { 
    protocol = local.udp_protocol
    source   = var.vcn_cidr_block

    udp_options {
      min = local.FS_min
      max = local.FS_min
    }
  }
  //--

  ingress_security_rules {
    protocol  = local.icmp_protocol
    source    = local.anywhere
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }

   // allow inbound icmp traffic of ping
  # ingress_security_rules {
  #   protocol  = local.icmp_protocol
  #   source    = local.anywhere
  #   stateless = true

  #   icmp_options {
  #     type = 0
  #   }
  # }
  # // allow inbound icmp traffic of ping
  # ingress_security_rules {
  #   protocol  = local.icmp_protocol
  #   source    = local.anywhere
  #   stateless = true

  #   icmp_options {
  #     type = 8
  #   }
  # }
  
}
