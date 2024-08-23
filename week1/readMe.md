# DEZoomcamp2024

## Main Points

1. [**Installation Environment Setup**](#installation-environment-setup)
   - This section covers setting up the development environment using GitHub Codespaces. It includes installing necessary tools like Terraform, Jupyter Notebook, PostgreSQL, and pgAdmin via Docker.

2. [**Data Ingestion**](#data-ingestion)
   - This section explains how to create a Python script for ingesting data into a PostgreSQL database and running the script both locally and using Docker. It also covers building a Docker image and running it within a Docker network.

3. [**Setting Up pgAdmin and PostgreSQL with `docker-compose`**](#setting-up-pgadmin-and-postgresql-with-docker-compose)
   - This section details how to configure and manage PostgreSQL and pgAdmin using a `docker-compose` file, making complex Docker setups easier to handle.

4. [**Starting with Terraform**](#starting-with-terraform)
   - This section introduces Terraform, a tool for building, changing, and versioning infrastructure safely and efficiently. It includes setting up a GCP account, creating a service account, and configuring Terraform to manage resources like Google Cloud Storage and BigQuery.

5. [**Terraform with Variables**](#terraform-with-variables)
   - This section extends the Terraform setup by introducing variables to make the configuration more modular and reusable. It also shows how to clean up previous configurations and apply new ones using these variables.

## Week 1

### Installation Environment Setup

Using GitHub Codespace:

- [YouTube Tutorial](https://www.youtube.com/watch?v=XOSUt8Ih3zA&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb)
- [GitHub Codespaces](https://github.com/features/codespaces)

1. **Create GitHub Repository**

    [DEZoomcamp2024 Repository](https://github.com/muhajir29/DEZoomcamp2024)

2. **Create Codespace**

    Open a Codespace in Visual Studio Code. The Codespace comes with Python and some packages pre-installed. Docker can be installed within Visual Studio Code.

3. **Install Terraform**

    [Terraform Installation Guide](https://developer.hashicorp.com/terraform/install#Linux)

4. **Install Jupyter Notebook**

    ```bash
    pip install jupyter
    ```

5. **Install PostgreSQL and pgAdmin with Docker**

    - **Create Network**

        ```bash
        docker network create pg-network
        ```

    - **Create Volume**

        ```bash
        docker volume create --name dtc_postgres_volume_local -d local
        ```

    - **Create Docker PostgreSQL**

        ```bash
        docker run -it \
        -e POSTGRES_USER="root" \
        -e POSTGRES_PASSWORD="root" \
        -e POSTGRES_DB="ny_taxi" \
        -v dtc_postgres_volume_local:/var/lib/postgresql/data  \
        -p 5432:5432 \
        --network=pg-network \
        --name pg-database \
        postgres:13
        ```

    - **Create Docker pgAdmin**

        ```bash
        docker run -it \
        -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
        -e PGADMIN_DEFAULT_PASSWORD="root" \
        -p 8080:80 \
        --network=pg-network \
        --name pgadmin \
        dpage/pgadmin4
        ```

### Data Ingestion

1. **Create `ingest_data.py` Script**

2. **Install Required Packages**

    ```bash
    pip install pandas sqlalchemy psycopg2
    ```

3. **Run the Ingestion Script**

    ```bash
    URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"
    
    python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_trips \
    --url=${URL}
    ```

### Data Ingestion with Dockerfile

1. **Create Dockerfile**

2. **Build Docker Image**

    ```bash
    docker build -t <image-name> .
    ```

    Example:

    ```bash
    docker build -t ingest_data .
    ```

3. **Run the Ingestion Script with Docker**

    ```bash
    docker run -it \
    --network=pg-network \
    ingest_data:latest \
        --user=root \
        --password=root \
        --host=pg-database \
        --port=5432 \
        --db=ny_taxi \
        --table_name=yellow_taxi_trips_docker \
        --url=${URL}
    ```

### Setting Up pgAdmin and PostgreSQL with `docker-compose`

Before creating a new Docker container and image, it is recommended to prune (remove all) containers and images with the following commands:

- **Delete All Containers**

    ```bash
    docker container prune
    ```

- **Delete All Images**

    ```bash
    docker image prune --all
    ```

1. **Create `docker-compose.yaml` File**

2. **Build and Run `docker-compose`**

    ```bash
    docker-compose up -d 
    ```

3. **Shutdown `docker-compose`**

    ```bash
    docker-compose down
    ```

### Starting with Terraform

**Terraform Basics**: [YouTube Tutorial](https://www.youtube.com/watch?v=Y2ux7gq3Z0o)

1. **Create GCP Account**

2. **Create a New Directory for Terraform**

    ```bash
    mkdir terraform_learning
    cd terraform_learning 
    ```

3. **Create Service Account with Key in `.json` (Credentials)**

    - Download credentials in `.json` format.

    - Export credentials to the local environment:

        ```bash
        export GOOGLE_CREDENTIALS='path-to-json-file'
        ```

        Example:

        ```bash
        export GOOGLE_CREDENTIALS='/workspaces/DEZoomcamp2024/week1/terraform/training-de.json'
        ```

        Confirm with:

        ```bash
        echo $GOOGLE_CREDENTIALS
        ```

4. **Create `main.tf` File**

    Documentation can be found at [Terraform Registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

    Example for setting up infrastructure with Google Cloud Storage (GCS):

    ```hcl
    terraform {
        required_providers {
            google = {
                source = "hashicorp/google"
                version = "5.13.0"
            }
        }
    }

    provider "google" {
        project     = "my-project"
        region      = "us-central1"
    }

    resource "google_storage_bucket" "training-de" {
        name          = "training-de"
        location      = "US"
        force_destroy = true

        lifecycle_rule {
            condition {
                age = 1
            }
            action {
                type = "AbortIncompleteMultipartUpload"
            }
        }
    }
    ```

5. **Initialize Terraform**

    ```bash
    terraform init
    ```

6. **Plan Terraform Execution**

    ```bash
    terraform plan
    ```

7. **Apply Terraform Configuration**

    ```bash
    terraform apply
    ```

8. **Destroy Terraform Resources**

    ```bash
    terraform destroy
    ```

### Terraform with Variables

1. **Clean Up Previous Credentials Setup**

    Unset the previously exported `GOOGLE_CREDENTIALS`:

    ```bash
    unset GOOGLE_CREDENTIALS
    ```

    Verify the cleanup:

    ```bash
    echo $GOOGLE_CREDENTIALS
    ```

    (The output should be empty.)

2. **Create `variables.tf` File**

    Store variable values for `main.tf`:

    ```hcl
    variable "credentials" {
        description = "My Credentials"
        default = "./<path-to-json-credential.json>"
    }

    variable "project" {
        description = "My Project Name"
        default = "My-Project-ID"
    }

    variable "region" {
        description = "Region"
        default = "us-central1"
    }

    variable "location" {
        description = "Project Location"
        default = "US"    
    }

    variable "bq_dataset_name" {
        description = "My BigQuery Dataset Name"
        default     = "training_de_dataset"
    }

    variable "gcs_bucket_name" {
        description = "My Storage Bucket Name"
        default     = "training_de_bucket"
    }

    variable "gcs_storage_class" {
        description = "Bucket Storage Class"
        default     = "STANDARD"
    }
    ```

3. **Modify `main.tf` to Use Variables**

    Update `main.tf` to reference the variables from `variables.tf`:

    ```hcl
    terraform {
        required_providers {
            google = {
                source = "hashicorp/google"
                version = "5.13.0"
            }
        }
    }

    provider "google" {
        credentials = file(var.credentials)
        project     = var.project
        region      = var.region
    }

    resource "google_storage_bucket" "demo-bucket" {
        name          = var.gcs_bucket_name
        location      = var.location
        force_destroy = true

        lifecycle_rule {
            condition {
                age = 1
            }
            action {
                type = "AbortIncompleteMultipartUpload"
            }
        }
    }

    resource "google_bigquery_dataset" "dataset" {
        dataset_id = var.bq_dataset_name
        project    = var.project
        location   = var.location
    }
    ```

4. **Reinitialize Terraform**

    ```bash
    terraform init
    ```

5. **Apply the Configuration**

    ```bash
    terraform apply
    ```

6. **Destroy Resources**

    ```bash
    terraform destroy
    ```
