output "bucket_name" {
  value = google_storage_bucket.flights_bucket.name
}

output "service_account_email" {
  value = google_service_account.pipeline_sa.email
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.flights_dataset.dataset_id
}