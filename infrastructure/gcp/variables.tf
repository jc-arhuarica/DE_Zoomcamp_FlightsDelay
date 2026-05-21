variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "bucket_name" {
  description = "GCS bucket name"
  default     = "de-zoomcamp-flightsdelay-jc-arhuarica"
}

variable "dataset_id" {
  description = "BigQuery dataset"
  default     = "flights_dataset"
}