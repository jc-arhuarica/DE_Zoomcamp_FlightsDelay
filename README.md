# ✈️ Flights Delay Analytics Pipeline (End-to-End Data Engineering Project)

## 📌 Problem Description

Flight delays are a major operational and financial issue for airlines and passengers. The goal of this project is to build an end-to-end data engineering pipeline that processes raw flight delay data, transforms it into analytics-ready datasets, and makes it available for business intelligence and decision-making.

This project answers key questions such as:
- What are the main causes of flight delays?
- Which airlines and airports experience the most delays?
- How do delay patterns vary over time?

The final output is a cloud-based analytics pipeline with automated ingestion, transformation, and reporting layers.

---

## ☁️ Cloud Architecture

This project is fully developed in the cloud using:

- **Snowflake** → Data warehouse (raw + transformed layers)
- **Google Cloud Storage (GCS)** → Data lake storage
- **BigQuery** → Analytics serving layer
- **Kestra** → Workflow orchestration (Infrastructure-as-Code style pipelines)
- **dbt** → Data transformations

All infrastructure and workflows are defined as code using Kestra YAML pipelines.

---

## 🔄 High-Level Architecture

<img width="5364" height="1804" alt="image" src="https://github.com/user-attachments/assets/c28eef1f-5434-4e4e-9967-a8f15cdb3cdf" />

---

## ⚙️ Workflow Orchestration (Kestra)

The pipeline includes the following automated steps:

1. Load raw flight data into Snowflake (COPY INTO)
2. Run dbt transformations (staging + marts)
3. Export fact and dimension tables from Snowflake to GCS
4. Load processed data into BigQuery

This ensures a fully automated end-to-end data pipeline.

---

## 🏗️ Data Warehouse Design

Snowflake is used as the central data warehouse with a multi-layer architecture:

### RAW Layer
- Raw ingestion from GCS

### STAGING Layer (dbt)
- Cleaned and standardized data

### MART Layer
- Analytics-ready tables:
  - `FCT_FLIGHT_DELAYS`
  - `DIM_DELAY_CAUSES`

### Optimization

The data warehouse tables are optimized using clustering to improve query performance and reduce scan costs.

Fact table (fct_flight_delays)
The table is clustered by flight_date and airport, which are commonly used in analytical queries.

flight_date: enables efficient time-based filtering (e.g., monthly or yearly trends)
airport: supports high-cardinality filtering for airport-level analysis

A derived flight_date column (from year and month) is used to simulate partitioning behavior and improve pruning efficiency.

👉 Benefits:

- Reduced data scanned (better pruning)
- Faster query execution
- Lower compute cost

---

## 🔧 Transformations (dbt)

All transformations are implemented using **dbt**, including:

- Data cleaning
- Joins between flight and delay data
- Aggregation of delay metrics
- Creation of fact and dimension tables

dbt ensures modular, version-controlled SQL transformations.

---

## 📊 Dashboard

A Looker Studio dashboard is built on top of BigQuery with:

### Key Metrics:
- Total delay minutes by airline
- Top delay causes
- Delay trends over time

### Dashboard Features:
- Interactive filters (airline, airport, date)
- Comparative analysis across carriers

Interactive dashboard built with Looker Studio:

👉 [https://lookerstudio.google.com/reporting/FlightsDelayDashboard](https://datastudio.google.com/reporting/3ca21ab7-60e1-44a5-89b3-06a8134379eb)

---

## ☁️ Data Ingestion

Batch ingestion pipeline:
- Flight data is stored in GCS
- Loaded into Snowflake using scheduled Kestra workflows

---

## 🔁 Reproducibility

### Prerequisites
- Snowflake account
- Google Cloud project
- Kestra instance

### Setup Steps

1. Clone repository
```bash
git clone https://github.com/JC-CC-UNI/DE_Zoomcamp_FlightsDelay.git
```
2. Configure Kestra KV store:
SNOWFLAKE_PRIVATE_KEY
GCP_SERVICE_ACCOUNT_JSON_B64

3. Run Kestra flow:
```
flights_pipeline.yml
```

4. Verify outputs:
Snowflake MART tables
GCS exported files
BigQuery dataset: flights_dataset


## 🚀 Technologies Used
Snowflake
Google Cloud Storage
BigQuery
dbt
Kestra
Python
SQL

## 📌 Future Improvements
Add streaming ingestion (Kafka or Pub/Sub)
Implement CI/CD for dbt models
Add data quality tests (dbt tests or Great Expectations)
Expand dashboard with predictive delay modeling

## 👤 Author

JC - Data Engineering Project (Zoomcamp Capstone)
