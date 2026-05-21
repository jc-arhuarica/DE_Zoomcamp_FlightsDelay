terraform {
  required_version = ">= 1.5"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.98"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

#####################################
# ACCOUNTADMIN PROVIDER
#####################################
provider "snowflake" {
  alias = "accountadmin"

  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account_name

  user     = var.snowflake_user
  password = var.snowflake_password

  role = "ACCOUNTADMIN"
}

#####################################
# SYSADMIN PROVIDER
#####################################

provider "snowflake" {
  alias = "sysadmin"

  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account_name

  user     = var.snowflake_user
  password = var.snowflake_password

  role     = "SYSADMIN"
}

provider "google" {
  project = var.project_id
  region  = var.region
}