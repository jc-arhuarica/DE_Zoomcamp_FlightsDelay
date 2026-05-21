#!/bin/bash
set -e

echo "=================================================="
echo "Setting up Data Engineering Environment"
echo "=================================================="

WORKSPACE_DIR="/workspaces/DE_Zoomcamp_FlightsDelay"

#
# System Dependencies
#
echo "---------------- Fixing Broken Repositories ----------------"

# Remove problematic Yarn repo if it exists
sudo rm -f /etc/apt/sources.list.d/yarn.list

# Remove old yarn gpg key if exists
sudo apt-key del 62D54FD4003F6525 2>/dev/null || true

echo "---------------- Install System Dependencies ----------------"

sudo apt-get clean
sudo apt-get update

sudo apt-get install -y \
    curl \
    unzip \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates \
    lsb-release

#
# Install Terraform
#
echo "---------------- Installing Terraform ----------------"

TERRAFORM_VERSION="1.9.8"
TF_ZIP="/tmp/terraform.zip"

wget -q \
  "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  -O "$TF_ZIP"

unzip -o "$TF_ZIP" -d /tmp

sudo mv /tmp/terraform /usr/local/bin/terraform
sudo chmod +x /usr/local/bin/terraform

terraform -version

rm -f "$TF_ZIP"

#
# Install Google Cloud SDK (gcloud, bq, gsutil)
#
#
# Install Google Cloud SDK (gcloud, bq, gsutil)
#
echo "---------------- Installing Google Cloud SDK ----------------"

if [ ! -f /usr/share/keyrings/cloud.google.gpg ]; then
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
fi

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

sudo apt-get update

sudo apt-get install -y --no-install-recommends \
    google-cloud-cli

echo "Installed versions:"
gcloud --version

if command -v bq &> /dev/null; then
    bq version
fi

if command -v gsutil &> /dev/null; then
    gsutil version
fi
#
# Python Environment
#
echo "---------------- Install Python Requirements ----------------"

if [ ! -d ".data_eng_env" ]; then
    python3 -m venv .data_eng_env
fi

source .data_eng_env/bin/activate

python -m pip install --upgrade pip
pip install -r requirements.txt

#
# DBT Setup
#
echo "---------------- DBT Setup ----------------"

mkdir -p "$HOME/.dbt"

cp .devcontainer/samples/profiles.yml "$HOME/.dbt/profiles.yml"

DBT_PROJECT_DIR=${1:-"./models_dbt"}

dbt deps --project-dir "$DBT_PROJECT_DIR"

#
# Auto-load .env
#
echo "---------------- Configure Environment ----------------"

if ! grep -q "source.*.env" "$HOME/.bashrc"; then
cat <<EOF >> "$HOME/.bashrc"

# Auto-load project .env
if [ -f ${WORKSPACE_DIR}/.env ]; then
    set -a
    source ${WORKSPACE_DIR}/.env
    set +a
fi
EOF
fi

echo "=================================================="
echo "Environment setup complete"
echo "Rebuild container or run:"
echo "source ~/.bashrc"
echo "=================================================="