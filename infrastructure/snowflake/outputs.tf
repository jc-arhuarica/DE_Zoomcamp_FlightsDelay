output "storage_integration_name" {
  value = snowflake_storage_integration.gcs_integration.name
}

output "gcs_service_account" {
  value = snowflake_storage_integration.gcs_integration.storage_gcp_service_account
}

output "allowed_locations" {
  value = snowflake_storage_integration.gcs_integration.storage_allowed_locations
}