# use ${module.<name>.compartment_ocid}
# If compartment not created: 
# module "env_compartment" {
#   source = "./modules/compartment"
#   tenancy_ocid = var.tenancy_ocid
#   compartment_name = var.compartment_name
#   description = var.compartment_desc
#   enable_delete = "false" // true will cause this compartment to be deleted when running `terrafrom destroy`
# }

module "env_vcn" {
  source = "./modules/vcn"
  compartment_ocid = var.compartment_ocid
  region = var.region 
  prefix = var.prefix

  vcn_cidr_block = var.vcn_cidr 
}

module "env_subnets" {
  source = "./modules/subnets"
  compartment_ocid = var.compartment_ocid
  vcn_ocid = module.env_vcn.vcn_ocid
  rt_public = module.env_vcn.public_rt_ocid
  rt_private = module.env_vcn.private_rt_ocid
  default_dhcp_ocid = module.env_vcn.default_dhcp_ocid

  prefix = var.prefix
  vcn_cidr_block = var.vcn_cidr
  public_subnet_cidr_block = var.public_subnet_cidr 
  db_subnet_cidr_block = var.db_subnet_cidr
}

# workloads, Bastion, SFTP, Script, EDQ, Database

# Remote execution to mount file system storage
data "template_file" "cloud-config" {
  template = <<YAML
  #cloud-config
  runcmd:
  - echo 'This instance was provisioned by Terraform.' >> /home/opc/install_log.txt 
  - sudo yum -y install nfs-utils > /home/opc/nfs-utils-install.log
  - sudo mkdir -p /mnt${var.fs_mount_path_folder}
  - sudo mount ${module.file_storage_env.private_ip}:${var.fs_mount_path_folder} /mnt${var.fs_mount_path_folder}
  - df -H >> /home/opc/nfs-utils-install.log
  YAML
}

module "edq_env" {
  source = "./modules/compute"
  compartment_ocid = var.compartment_ocid
  tenancy_ocid = var.tenancy_ocid
  subnet_ocid = module.env_subnets.public_subnet_ocid
  availability_domain = var.availability_domain
  region = var.region
  instance_image_ocid = local.edq_image

  ssh_public_keys = [var.ssh_public_key]
  instance_shape = var.edq_shape
  compute_display_name = "${var.prefix} EDQ"
  instance__boot_volume_size = var.edq_size
  assign_public_ip = false

  remote_exec = data.template_file.cloud-config.rendered
}

module "sftp_env" {
  source = "./modules/compute"
  compartment_ocid = var.compartment_ocid
  tenancy_ocid = var.tenancy_ocid
  subnet_ocid = module.env_subnets.public_subnet_ocid
  availability_domain = var.availability_domain
  region = var.region
  instance_image_ocid = local.autonomous_linux[var.region]

  ssh_public_keys = [var.ssh_public_key]
  instance_shape = var.sftp_shape
  compute_display_name = "${var.prefix} SFTP"
  instance__boot_volume_size = var.sftp_size
  assign_public_ip = false

  remote_exec = data.template_file.cloud-config.rendered
}

module "bastion_env" {
  source = "./modules/compute"
  compartment_ocid = var.compartment_ocid
  tenancy_ocid = var.tenancy_ocid
  subnet_ocid = module.env_subnets.public_subnet_ocid
  availability_domain = var.availability_domain
  region = var.region
  instance_image_ocid = local.autonomous_linux[var.region]

  ssh_public_keys = [var.ssh_public_key]
  instance_shape = var.bastion_shape
  compute_display_name = "${var.prefix} Bastion"
  instance__boot_volume_size = var.bastion_size
  assign_public_ip = false
}

# Following not used since public IP already created / assumed to be created
# You can use terraform import and the following resource to attach an already created Public reserved IP
# Give public IP to the SFTP server. Assign public ip must be false at deployment
# resource "oci_core_public_ip" "TFpublic_ip" {
#     #Required
#     compartment_id = var.compartment_ocid
#     lifetime = "RESERVED"
#     display_name = "${var.prefix}_sftp_ip"
#     private_ip_id = data.oci_core_private_ips.TFprivate_ips_by_vnic.private_ips[0].id
# }
# # Need to find the id for the specific private IP on the S
# data "oci_core_private_ips" "TFprivate_ips_by_vnic" {
#     ip_address = module.sftp_env.private_ip
#     subnet_id = module.env_subnets.public_subnet_ocid
# } 

module "object_storage_env" {
  source = "./modules/objectstorage"
  compartment_ocid = var.compartment_ocid
  bucket_name = "${var.prefix}_ObjStr" 
  bucket_access_type = "NoPublicAccess"
  bucket_storage_tier = "Standard"
}

module "file_storage_env" {
  source = "./modules/file_storage"
  compartment_ocid = var.compartment_ocid
  tenancy_ocid = var.tenancy_ocid
  availability_domain = var.availability_domain
  file_system_display_name = "${var.prefix}_FSS"

  public_subnet_ocid = module.env_subnets.public_subnet_ocid
  public_mount_target_display_name = "PublicMount"
  public_export_path = var.fs_mount_path_folder

  # private_subnet_ocid = module.env_subnets.private_subnet_ocid
  # private_mount_target_display_name = "PrivateMount"
  # private_export_path = var.fs_mount_path_folder
}

module "database_env" {
  source = "./modules/database"
  availability_domain = var.availability_domain 
  tenancy_ocid = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid

  subnet_ocid = module.env_subnets.database_subnet_ocid
  db_display_name = "${var.prefix}_database" //db system display name
  db_shape = var.db_shape
  db_node_count = "1"
  db_ssh_public_keys = [var.ssh_public_key]
  db_data_storage_size_in_gb = var.db_size
  
  db_version = var.db_version
  db_edition = var.db_edition
  db_home_display_name = "homedb" 
  db_hostname = var.db_hostname
  db_home_name = var.db_main_name
  db_pdb_name = var.db_pdb_name
  db_home_admin_password = var.db_admin_password
}