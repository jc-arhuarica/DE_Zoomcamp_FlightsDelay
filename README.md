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

<img width="5364" height="2084" alt="image" src="https://github.com/user-attachments/assets/22152808-3af5-4f54-a916-a1aab5fe9038" />

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

## 🔐 Security & Access Design

The project follows a **least-privilege architecture** by separating infrastructure provisioning from pipeline execution.

### Service Accounts

#### Terraform Service Account
`de-zoomcamp-flightsdelay-tf`

Used only for infrastructure provisioning through Terraform.

Responsibilities:
- Create GCS buckets
- Create BigQuery datasets
- Configure IAM roles
- Provision Snowflake integrations

This account has elevated permissions but is never used during data processing.

#### Pipeline Service Account
`flights-pipeline-sa`

Used by Kestra workflows and Python ingestion jobs.

Responsibilities:
- Upload files to GCS
- Load data into BigQuery
- Access Snowflake integrations

This account has limited permissions and follows least-privilege principles.

### Authentication Flow

```text
Terraform Service Account
        ↓ provisions infrastructure

Pipeline Service Account
        ↓ executes ingestion

Kestra
    ↓
Snowflake
    ↓
dbt
    ↓
GCS
    ↓
BigQuery
```
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
  - `FCT_FLIGHTS_DELAY`
  - `DIM_DELAY_CAUSES`

### Optimization

The data warehouse tables are optimized using clustering to improve query performance and reduce scan costs.

Fact table (fct_flights_delay)
The table is clustered by flight_date and airport, which are commonly used in analytical queries.

flight_date: enables efficient time-based filtering (e.g., monthly or yearly trends)
airport: supports high-cardinality filtering for airport-level analysis

A derived flight_date column (from year and month) is used to simulate partitioning behavior and improve pruning efficiency.

👉 Benefits:

- Reduced data scanned (better pruning)
- Faster query execution
- Lower compute cost

<!--- <img width="3864" height="1844" alt="image" src="https://github.com/user-attachments/assets/e3d7da0a-d789-440a-a033-4e1428c24b09" />
<img width="4084" height="2164" alt="image" src="https://github.com/user-attachments/assets/ba04cb2f-e8f3-4e35-acce-92b6650591c7" /> --->
<img width="4084" height="2164" alt="image" src="https://github.com/user-attachments/assets/523b9054-ae1e-4b37-becc-c8e49303576e" />


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


<!--- ### Dashboard Preview
<img width="1066" height="807" alt="image" src="https://github.com/user-attachments/assets/f2174cea-e3d6-4636-8cd6-2d471ae97f25" />
<img width="1066" height="807" alt="image" src="https://github.com/user-attachments/assets/e4472fdf-6c8d-47d3-9c5f-354880e85139" />
### Dashboard Preview

| | |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/f2174cea-e3d6-4636-8cd6-2d471ae97f25" width="49%"> | <img src="https://github.com/user-attachments/assets/e4472fdf-6c8d-47d3-9c5f-354880e85139" width="49%"> |--->

### Dashboard Preview

<img src="https://github.com/user-attachments/assets/f2174cea-e3d6-4636-8cd6-2d471ae97f25" width="49%" /> <img src="https://github.com/user-attachments/assets/e4472fdf-6c8d-47d3-9c5f-354880e85139" width="49%" />

#### Interactive dashboard built with Looker Studio:

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

- Google Cloud account
- Snowflake account
- Kaggle account
- Kestra instance
- Docker + VS Code Dev Containers

---

### 1. Clone Repository

```bash
git clone https://github.com/jc-arhuarica/DE_Zoomcamp_FlightsDelay.git
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

### 3. Authenticate with Google Cloud

Login to Google Cloud:

```bash
gcloud auth login
```

List available accounts:

```bash
gcloud auth list
```

Set your billing-enabled account if needed:

```bash
gcloud config set account <your-email>
```

---

### 4. Create Google Cloud Project

Create a new project:

```bash
gcloud projects create de-zoomcamp-flightsdelay-dev
```

Set the project:

```bash
gcloud config set project de-zoomcamp-flightsdelay-dev
```

Enable required APIs:

```bash
gcloud services enable \
iam.googleapis.com \
cloudresourcemanager.googleapis.com \
serviceusage.googleapis.com \
storage.googleapis.com \
bigquery.googleapis.com
```

---

### 5. Create Terraform Service Account

Create the Terraform service account:

```bash
gcloud iam service-accounts create \
de-zoomcamp-flightsdelay-tf \
--display-name="Terraform Service Account"
```

Assign required roles:

<!--- ```bash
PROJECT_ID=de-zoomcamp-flightsdelay-dev
TF_SA="de-zoomcamp-flightsdelay-tf@$PROJECT_ID.iam.gserviceaccount.com"

for role in \
roles/bigquery.admin \
roles/resourcemanager.projectIamAdmin \
roles/iam.serviceAccountAdmin \
roles/iam.serviceAccountKeyAdmin \
roles/serviceusage.serviceUsageAdmin \
roles/storage.admin
do
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$TF_SA" \
    --role="$role"
done
```--->
```bash
gcloud projects add-iam-policy-binding de-zoomcamp-flightsdelay-dev \
--member="serviceAccount:de-zoomcamp-flightsdelay-tf@de-zoomcamp-flightsdelay-dev.iam.gserviceaccount.com" \
--role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding de-zoomcamp-flightsdelay-dev \
--member="serviceAccount:de-zoomcamp-flightsdelay-tf@de-zoomcamp-flightsdelay-dev.iam.gserviceaccount.com" \
--role="roles/storage.admin"

gcloud projects add-iam-policy-binding de-zoomcamp-flightsdelay-dev \
--member="serviceAccount:de-zoomcamp-flightsdelay-tf@de-zoomcamp-flightsdelay-dev.iam.gserviceaccount.com" \
--role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding de-zoomcamp-flightsdelay-dev \
--member="serviceAccount:de-zoomcamp-flightsdelay-tf@de-zoomcamp-flightsdelay-dev.iam.gserviceaccount.com" \
--role="roles/iam.serviceAccountKeyAdmin"

gcloud projects add-iam-policy-binding de-zoomcamp-flightsdelay-dev \
--member="serviceAccount:de-zoomcamp-flightsdelay-tf@de-zoomcamp-flightsdelay-dev.iam.gserviceaccount.com" \
--role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding de-zoomcamp-flightsdelay-dev \
--member="serviceAccount:de-zoomcamp-flightsdelay-tf@de-zoomcamp-flightsdelay-dev.iam.gserviceaccount.com" \
--role="roles/resourcemanager.projectIamAdmin"
```

Generate Terraform SA key:

<!--- ```bash
gcloud iam service-accounts keys create \
~/gcp-key.json \
--iam-account=$TF_SA
```--->
```bash
gcloud iam service-accounts keys create \
~/gcp-key.json \
--iam-account=de-zoomcamp-flightsdelay-tf@de-zoomcamp-flightsdelay-dev.iam.gserviceaccount.com
```

Move the key:

```bash
mkdir -p keys
mv ~/gcp-key.json keys/gcp-key.json
```

Authenticate using Terraform SA:

```bash
gcloud auth activate-service-account \
--key-file=keys/gcp-key.json
```

Verify authentication:

```bash
gcloud auth list
```

---

### 6. Generate Snowflake RSA Keys

Generate RSA private and public keys used for Snowflake key-pair authentication.

Private key:

```bash
openssl genrsa 2048 | \
openssl pkcs8 -topk8 \
-inform PEM \
-out keys/rsa_key.p8 \
-nocrypt
```

Public key:

```bash
openssl rsa \
-in keys/rsa_key.p8 \
-pubout \
-out keys/rsa_key.pub
```

Verify generated files:

```text
keys/
├── rsa_key.p8
└── rsa_key.pub
```

These keys are used by Terraform to provision the Snowflake service user:

```text
SERVICE_USER_DBT_ACCOUNT
```

The public key is automatically injected through:

```text
TF_VAR_rsa_public_key
```

---

### 7. Provision Infrastructure (Terraform)

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

### 8. Generate Pipeline Service Account Key

Generate the runtime service account key:

```bash
gcloud iam service-accounts keys create \
~/flights-pipeline-sa-key.json \
--iam-account=flights-pipeline-sa@<project-id>.iam.gserviceaccount.com
```

Move the key into:

```text
mv ~/flights-pipeline-sa-key.json keys/flights-pipeline-sa-key.json
```

---

### 10. Start Kestra Locally (Docker Compose)

This project runs Kestra locally using Docker Compose.

Start Kestra services:

```bash
docker compose up -d
```
Verify containers are running:
```bash
docker ps
```

Expected services:

```text
kestra
kestra_postgres
```

Access Kestra UI:
```text
http://localhost:8080
```

Default credentials:

```text
Username: admin@kestra.io
Password: Admin1234!
```

---

### 9. Configure Kestra KV Store

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

### 10. Configure Environment Variables

Create `.env` file:

```bash
cp .env.example .env
```

Populate required variables.

---

### 11. Deploy Kestra Flow

Open Kestra UI.

Create a new flow and paste:

```text
kestra/flows/flights_pipeline.yml
```

Save the flow.

---

### 12. Execute Pipeline

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

### 13. Verify Outputs

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
├── .devcontainer/              # VSCode DevContainer setup
│
├── infrastructure/             # Terraform IaC
│   ├── gcp/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── provider.tf
│   │
│   └── snowflake/
│       ├── main.tf
│       ├── variables.tf
│       └── providers.tf
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
├── data/                       # Optional local raw/sample files
│
├── .env.example                # Environment variable template
├── docker-compose.yml          # Kestra local deployment
├── requirements.txt
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
