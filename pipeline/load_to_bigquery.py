from google.cloud import bigquery
import os
import argparse

#os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/workspace/keys/gcp-key.json"

PROJECT_ID = "kestra-sandbox-487804"
DATASET_ID = "flights_dataset"


def load_table(table_id, gcs_uri):
    client = bigquery.Client(project=PROJECT_ID)

    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{table_id}"

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=True,
        write_disposition="WRITE_TRUNCATE",
    )

    print(f"Loading {table_id} from {gcs_uri}...")

    load_job = client.load_table_from_uri(
        gcs_uri,
        table_ref,
        job_config=job_config,
    )

    load_job.result()
    print(f"✅ {table_id} loaded!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--table", required=True)
    parser.add_argument("--uri", required=True)

    args = parser.parse_args()

    load_table(args.table, args.uri)
