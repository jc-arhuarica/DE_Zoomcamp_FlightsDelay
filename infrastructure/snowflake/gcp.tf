resource "google_storage_bucket_iam_member" "snowflake_storage_viewer" {
  bucket = var.bucket_name

  role = "roles/storage.objectViewer"

  member = "serviceAccount:${snowflake_storage_integration.gcs_integration.storage_gcp_service_account}"

  depends_on = [
    snowflake_storage_integration.gcs_integration
  ]
}

resource "google_storage_bucket_iam_member" "snowflake_storage_creator" {
  bucket = var.bucket_name

  role = "roles/storage.objectCreator"

  member = "serviceAccount:${snowflake_storage_integration.gcs_integration.storage_gcp_service_account}"

  depends_on = [
    snowflake_storage_integration.gcs_integration
  ]
}