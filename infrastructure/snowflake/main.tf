#####################################
# DATABASE
#####################################

resource "snowflake_database" "flights_db" {
  provider = snowflake.sysadmin

  name = "DE_ZOOMCAMP_FLIGHTS_DB"
}

#####################################
# SCHEMAS
#####################################

resource "snowflake_schema" "raw" {
  provider = snowflake.sysadmin

  database = snowflake_database.flights_db.name
  name     = "RAW"
}

resource "snowflake_schema" "staging" {
  provider = snowflake.sysadmin

  database = snowflake_database.flights_db.name
  name     = "STAGING"
}

resource "snowflake_schema" "mart" {
  provider = snowflake.sysadmin

  database = snowflake_database.flights_db.name
  name     = "MART"
}

#####################################
# WAREHOUSE
#####################################

resource "snowflake_warehouse" "compute_wh" {
  provider = snowflake.sysadmin

  name                  = "DEV_WH"
  warehouse_size        = "XSMALL"
  auto_suspend          = 60
  auto_resume           = true
  initially_suspended   = true
}

#####################################
# FILE FORMAT
#####################################

resource "snowflake_file_format" "csv_format" {
  provider = snowflake.sysadmin

  depends_on = [
    snowflake_schema.raw
  ]

  database = snowflake_database.flights_db.name
  schema   = snowflake_schema.raw.name
  name     = "FLIGHTS_DELAY_FORMAT"

  format_type                  = "CSV"
  field_delimiter              = ","
  skip_header                  = 1
  field_optionally_enclosed_by = "\""
}

#####################################
# STORAGE INTEGRATION
#####################################

resource "snowflake_storage_integration" "gcs_integration" {
  provider = snowflake.accountadmin

  depends_on = [
    snowflake_database.flights_db
  ]

  name             = "GCS_FLIGHTSDELAY_INTEGRATION"
  storage_provider = "GCS"
  enabled          = true

  storage_allowed_locations = [
    "gcs://${var.bucket_name}/"
  ]
}

#####################################
# STAGES
#####################################

resource "snowflake_stage" "raw_stage" {
  provider = snowflake.sysadmin

  depends_on = [
    snowflake_storage_integration.gcs_integration,
    snowflake_file_format.csv_format
  ]

  name     = "FLIGHTS_DELAY_STAGE"
  database = snowflake_database.flights_db.name
  schema   = snowflake_schema.raw.name

  url = "gcs://${var.bucket_name}/flights/raw/flights_delay/"

  storage_integration = snowflake_storage_integration.gcs_integration.name

  file_format = "FORMAT_NAME = ${snowflake_database.flights_db.name}.${snowflake_schema.raw.name}.${snowflake_file_format.csv_format.name}"
}

resource "snowflake_stage" "fct_stage" {
  provider = snowflake.sysadmin

  depends_on = [
    snowflake_storage_integration.gcs_integration,
    snowflake_file_format.csv_format
  ]
  name                = "FCT_FLIGHTS_DELAY_STAGE"
  database            = snowflake_database.flights_db.name
  schema              = snowflake_schema.mart.name

  url                 = "gcs://${var.bucket_name}/flights/mart/fct_flights_delay/"

  storage_integration = snowflake_storage_integration.gcs_integration.name
  file_format = "FORMAT_NAME = ${snowflake_database.flights_db.name}.${snowflake_schema.raw.name}.${snowflake_file_format.csv_format.name}"
}

resource "snowflake_stage" "dim_stage" {
  provider = snowflake.sysadmin

  depends_on = [
    snowflake_storage_integration.gcs_integration,
    snowflake_file_format.csv_format
  ]
  name                = "DIM_DELAY_CAUSES_STAGE"
  database            = snowflake_database.flights_db.name
  schema              = snowflake_schema.mart.name

  url                 = "gcs://${var.bucket_name}/flights/mart/dim_delay_causes/"

  storage_integration = snowflake_storage_integration.gcs_integration.name
  file_format = "FORMAT_NAME = ${snowflake_database.flights_db.name}.${snowflake_schema.raw.name}.${snowflake_file_format.csv_format.name}"
}

#####################################
# DBT / KESTRA SERVICE USER
#####################################

resource "snowflake_user" "service_user_dbt" {
  provider = snowflake.accountadmin

  name                 = "SERVICE_USER_DBT_ACCOUNT"
  default_role         = "SYSADMIN"
  default_warehouse    = snowflake_warehouse.compute_wh.name
  default_namespace    = "${snowflake_database.flights_db.name}.RAW"

  rsa_public_key = var.rsa_public_key

  depends_on = [
    snowflake_warehouse.compute_wh,
    snowflake_schema.raw
  ]
}

#####################################
# ROLE GRANTS
#####################################

resource "snowflake_grant_account_role" "sysadmin_to_service_user" {
  provider = snowflake.accountadmin
  
  depends_on = [
    snowflake_user.service_user_dbt
  ]
  role_name = "SYSADMIN"
  user_name = snowflake_user.service_user_dbt.name
}


#####################################
# RAW TABLE
#####################################
resource "snowflake_table" "flights_delay" {
  provider = snowflake.sysadmin

  depends_on = [
    snowflake_schema.raw
  ]
  database = snowflake_database.flights_db.name
  schema   = snowflake_schema.raw.name
  name     = "FLIGHTS_DELAY"

  column {
    name = "YEAR"
    type = "INTEGER"
  }

  column {
    name = "MONTH"
    type = "INTEGER"
  }

  column {
    name = "CARRIER"
    type = "STRING"
  }

  column {
    name = "CARRIER_NAME"
    type = "STRING"
  }

  column {
    name = "AIRPORT"
    type = "STRING"
  }

  column {
    name = "AIRPORT_NAME"
    type = "STRING"
  }

  column {
    name = "ARR_FLIGHTS"
    type = "INTEGER"
  }

  column {
    name = "ARR_DEL15"
    type = "INTEGER"
  }

  column {
    name = "CARRIER_CT"
    type = "FLOAT"
  }

  column {
    name = "WEATHER_CT"
    type = "FLOAT"
  }

  column {
    name = "NAS_CT"
    type = "FLOAT"
  }

  column {
    name = "SECURITY_CT"
    type = "FLOAT"
  }

  column {
    name = "LATE_AIRCRAFT_CT"
    type = "FLOAT"
  }

  column {
    name = "ARR_CANCELLED"
    type = "INTEGER"
  }

  column {
    name = "ARR_DIVERTED"
    type = "INTEGER"
  }

  column {
    name = "ARR_DELAY"
    type = "INTEGER"
  }

  column {
    name = "CARRIER_DELAY"
    type = "INTEGER"
  }

  column {
    name = "WEATHER_DELAY"
    type = "INTEGER"
  }

  column {
    name = "NAS_DELAY"
    type = "INTEGER"
  }

  column {
    name = "SECURITY_DELAY"
    type = "INTEGER"
  }

  column {
    name = "LATE_AIRCRAFT_DELAY"
    type = "INTEGER"
  }
}