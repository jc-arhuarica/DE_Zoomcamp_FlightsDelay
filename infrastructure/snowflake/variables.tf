variable "snowflake_organization" {
  type = string
}

variable "snowflake_account_name" {
  type = string
}

variable "snowflake_user" {
  type = string
}

variable "snowflake_password" {
  type      = string
  sensitive = true
}

variable "bucket_name" {
  type    = string
  default = "de-zoomcamp-flightsdelay-jc-arhuarica"
}

variable "rsa_public_key" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}