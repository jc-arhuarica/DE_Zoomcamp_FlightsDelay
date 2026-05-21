import os
import requests
import zipfile
from pathlib import Path
from datetime import datetime

from google.cloud import storage
import subprocess


# ==============================
# CONFIG
# ==============================

DATA_URL = "https://www.kaggle.com/api/v1/datasets/download/daryaheyko/airline-on-time-statistics-and-delay-causes-bts"  # <-- replace with real URL
BASE_DIR = Path(__file__).resolve().parent.parent
LOCAL_DIR = BASE_DIR / "data"
BUCKET_NAME = "de-zoomcamp-flightsdelay-data"
GCS_PREFIX = "flights/raw"

# ==============================
# STEP 1: DOWNLOAD FILE
# ==============================

def download_kaggle_dataset():
    print("Downloading dataset from Kaggle...")
    subprocess.run([
        "kaggle",
        "datasets",
        "download",
        "-d",
        "daryaheyko/airline-on-time-statistics-and-delay-causes-bts",
        "-p",
        str(LOCAL_DIR),
        "--unzip"
    ], check=True)


# ==============================
# STEP 2: UPLOAD TO GCS
# ==============================

def upload_to_gcs(bucket_name: str, source_file: Path, destination_blob: str):
    print(f"Uploading {source_file} to GCS...")

    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(destination_blob)

    blob.upload_from_filename(str(source_file))

    print(f"Uploaded to gs://{bucket_name}/{destination_blob}")


# ==============================
# MAIN PIPELINE
# ==============================

def main():
    LOCAL_DIR.mkdir(exist_ok=True)

    #timestamp = datetime.now().strftime("%Y%m%d")

    #zip_path = LOCAL_DIR / f"flights_{timestamp}.zip"
    #extract_dir = LOCAL_DIR / f"flights_{timestamp}"

    # Step 1: Download
    download_kaggle_dataset()

    # Step 2: Upload all CSV files to GCS
    for file in LOCAL_DIR.glob("*.csv"):
        destination = f"{GCS_PREFIX}/{file.name}"
        upload_to_gcs(BUCKET_NAME, file, destination)


if __name__ == "__main__":
    main()
