# =========================
# GCS BUCKET
# =========================
resource "google_storage_bucket" "flights_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_project_service" "services" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}
# =========================
# SERVICE ACCOUNT (Kestra / Pipeline)
# =========================

resource "google_service_account" "pipeline_sa" {
  account_id   = "flights-pipeline-sa"
  display_name = "Flights Pipeline Service Account"

  depends_on = [
    google_project_service.services
  ]
}

# =========================
# SERVICE ACCOUNT KEY
# =========================
resource "google_service_account_key" "pipeline_sa_key" {
  service_account_id = google_service_account.pipeline_sa.name

  depends_on = [
    google_service_account.pipeline_sa
  ]
}

# =========================
# IAM ROLES FOR SERVICE ACCOUNT
# =========================

# Storage Admin (read/write GCS)
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"

  depends_on = [google_service_account.pipeline_sa]
}

# BigQuery Admin (load + write tables)
resource "google_project_iam_member" "bq_admin" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"

  depends_on = [google_service_account.pipeline_sa]
}

resource "google_project_iam_member" "bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"

  depends_on = [google_service_account.pipeline_sa]
}

# =========================
# BIGQUERY DATASET
# =========================
resource "google_bigquery_dataset" "flights_dataset" {
  dataset_id = var.dataset_id
  location   = var.region

  delete_contents_on_destroy = true
}

