output "bucket_name" {
  value = oci_objectstorage_bucket.TFbucket.name
}
output "bucket_ocid" {
  value = oci_objectstorage_bucket.TFbucket.id
}