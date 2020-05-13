# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Protocols are specified as protocol numbers.
# https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

locals {
  all_protocols    = "all"
  anywhere         = "0.0.0.0/0"
  
  ssh_port         = 22
  oracle_db_port   = 1521
  http_port        = 80
  https_port       = 443
  edq_port         = 2222
  JMX_port         = 8090 
  FS_min           = 2048
  FS_max           = 2050
  FS_port          = 111

  tcp_protocol     = 6
  icmp_protocol    = 1
  udp_protocol     = 17

}