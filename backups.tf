data "oci_core_volume_backup_policies" "TFbackup_policies" {
  filter {
    name   = "display_name"
    values = [var.boot_volume_policy_version]
  }
}

resource "oci_core_volume_backup_policy_assignment" "TFbackup_policy_assignment_sftp" {
  asset_id  = module.sftp_env.boot_volume_id
  policy_id = data.oci_core_volume_backup_policies.TFbackup_policies.volume_backup_policies.0.id
}

resource "oci_core_volume_backup_policy_assignment" "TFbackup_policy_assignment_edq" {
  asset_id  = module.edq_env.boot_volume_id
  policy_id = data.oci_core_volume_backup_policies.TFbackup_policies.volume_backup_policies.0.id
}

resource "oci_core_volume_backup_policy_assignment" "TFbackup_policy_assignment_bastion" {
  asset_id  = module.bastion_env.boot_volume_id
  policy_id = data.oci_core_volume_backup_policies.TFbackup_policies.volume_backup_policies.0.id
}
 

