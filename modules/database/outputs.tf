output "database_ocid" {
  value = oci_database_db_system.TFDatabaseSystem.id
}
output "db_connection" {
  value = oci_database_db_system.TFDatabaseSystem.db_home[0].database[0].connection_strings
}
 