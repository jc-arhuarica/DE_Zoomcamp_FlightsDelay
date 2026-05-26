# ✈️ Flights Delay Analytics Pipeline (End-to-End Data Engineering Project)

## Project Overview

This project builds a cloud-based end-to-end flight delay analytics pipeline.

The pipeline ingests raw data from Kaggle into Google Cloud Storage, processes and transforms it in Snowflake using dbt, exports curated datasets to BigQuery, and serves business intelligence dashboards in Looker Studio.

The workflow is orchestrated using Kestra and infrastructure is managed through Terraform.

---

## 📌 Problem Description

Flight delays are a major operational and financial issue for airlines and passengers. The goal of this project is to build an end-to-end data engineering pipeline that processes raw flight delay data, transforms it into analytics-ready datasets, and makes it available for business intelligence and decision-making.

This project answers key questions such as:
- What are the main causes of flight delays?
- Which airlines and airports experience the most delays?
- How do delay patterns vary over time?

The final output is a cloud-based analytics pipeline with automated ingestion, transformation, and reporting layers.

---

## 🔄 High-Level Architecture

<img width="5364" height="1804" alt="image" src="https://github.com/user-attachments/assets/1114aecc-452e-4276-bfc5-ef36960aa2be" />


---

## 🚀 Technologies Used

This project is fully developed in the cloud using:

- **Snowflake** → Data warehouse (raw + transformed layers)
- **Google Cloud Storage (GCS)** → Data lake storage
- **BigQuery** → Analytics serving layer
- **Kestra** → Workflow orchestration (Infrastructure-as-Code style pipelines)
- **dbt** → Data transformations
- **Terraform** → Infrastructure as Code (IaC) tool.

All infrastructure and workflows are defined as code using Kestra YAML pipelines and Terraform.

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

<img width="3164" height="2084" alt="image" src="https://github.com/user-attachments/assets/09791de4-2215-433f-9919-f0aac41c7c91" />


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

👉 [View Dashboard](https://datastudio.google.com/reporting/3ca21ab7-60e1-44a5-89b3-06a8134379eb)

---

## ☁️ Data Ingestion

Batch ingestion pipeline:
- Flight data is stored in GCS
- Loaded into Snowflake using scheduled Kestra workflows

---

## 🔁 Reproducibility

Follow the steps below to reproduce the project from scratch.

### Prerequisites

Required accounts and tools:

- Google Cloud Project
- Snowflake account
- Kaggle account
- Kestra instance
- Docker + VS Code Dev Containers

---

### 1. Clone Repository

```bash
git clone https://github.com/JC-CC-UNI/DE_Zoomcamp_FlightsDelay.git
cd DE_Zoomcamp_FlightsDelay
```

---

### 2. Open in Dev Container

This project uses a fully configured development container.

Open the repository in VS Code:

```text
Command Palette → Dev Containers: Reopen in Container
```

The container automatically installs:

- Terraform
- Google Cloud SDK
- dbt
- Python dependencies

---

### 3. Authenticate GCP

Create a Terraform service account with sufficient permissions.

Example:

```bash
gcloud auth login
gcloud config set project <your-project-id>
```

---

### 4. Provision Infrastructure (Terraform)

Provision cloud resources.

#### GCP Infrastructure

```bash
cd infrastructure/gcp

terraform init
terraform plan
terraform apply
```

#### Snowflake Infrastructure

```bash
cd ../snowflake

terraform init
terraform plan
terraform apply
```

This creates:

- GCS buckets
- BigQuery datasets
- Snowflake integrations
- IAM resources
- Pipeline service account

---

### 5. Generate Pipeline Service Account Key

Generate the runtime service account key:

```bash
gcloud iam service-accounts keys create \
~/flights-pipeline-sa-key.json \
--iam-account=flights-pipeline-sa@<project-id>.iam.gserviceaccount.com
```

Move the key into:

```text
keys/flights-pipeline-sa-key.json
```

---

### 6. Configure Kestra KV Store

Create the following KV variables in Kestra:

| Key | Description |
|------|-------------|
| `GCP_SERVICE_ACCOUNT_JSON_B64` | Base64-encoded pipeline service account JSON |
| `KAGGLE_API_TOKEN` | Kaggle API token |
| `SNOWFLAKE_PRIVATE_KEY` | RSA private key for Snowflake authentication |

Generate the base64 value:

```bash
cat keys/flights-pipeline-sa-key.json | base64
```

Copy the output into:

```text
GCP_SERVICE_ACCOUNT_JSON_B64
```

---

### 7. Configure Environment Variables

Create `.env` file:

```bash
cp .env.example .env
```

Populate required variables.

---

### 8. Deploy Kestra Flow

Open Kestra UI.

Create a new flow and paste:

```text
kestra/flows/flights_pipeline.yml
```

Save the flow.

---

### 9. Execute Pipeline

Run the Kestra flow manually.

Pipeline stages:

```text
Kaggle
   ↓
GCS (raw)
   ↓
Snowflake RAW
   ↓
dbt STAGING
   ↓
dbt MART
   ↓
Snowflake Export Stage
   ↓
GCS (processed)
   ↓
BigQuery
   ↓
Looker Studio
```

---

### 10. Verify Outputs

Successful execution should generate:

#### Snowflake
- `RAW.FLIGHTS_DELAY`
- `STAGING.STG_FLIGHTS`
- `MART.FCT_FLIGHTS_DELAY`
- `MART.DIM_DELAY_CAUSES`

#### GCS
- Raw files
- Processed exports

#### BigQuery
Dataset:
```text
flights_dataset
```

#### Dashboard
Looker Studio dashboard populated with data.


---

## 📁 Project Structure

The repository is organized into modular components for infrastructure, orchestration, transformation, and analytics delivery.

### Key Components
- **infrastructure/** → Terraform code for provisioning GCP and Snowflake resources
- **kestra/** → Workflow orchestration pipelines
- **models_dbt/** → Data transformation logic (staging + marts)
- **pipeline/** → Python scripts for ingestion and BigQuery loading
- **data/** → Local storage for raw or sample datasets

```text
DE_ZOOMCAMP_FLIGHTSDELAY/
│
├── .devcontainer/              # Development container setup
│
├── infrastructure/             # Infrastructure as Code (Terraform)
│   ├── gcp/
│   └── snowflake/
│
├── kestra/
│   └── flows/
│       └── flights_pipeline.yml
│
├── models_dbt/                 # dbt transformation project
│   ├── macros/
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   ├── dbt_project.yml
│   └── profiles.yml
│
├── pipeline/                   # Python ingestion/export scripts
│   ├── ingest_flights_data.py
│   └── load_to_bigquery.py
│
├── data/                       # Local sample/raw data
│
├── .env.example                # Environment variables template
├── docker-compose.yml          # Local orchestration setup
├── requirements.txt            # Python dependencies
├── README.md
└── LICENSE.txt
```

---

## 📌 Future Improvements
Add streaming ingestion (Kafka or Pub/Sub)
Implement CI/CD for dbt models
Add data quality tests (dbt tests or Great Expectations)
Expand dashboard with predictive delay modeling

## 👤 Author

JC - Data Engineering Project (Zoomcamp Capstone)
