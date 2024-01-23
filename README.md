# DEZoomcamp2024

## Week 1

### Installation Env

Using Gihthub code space

<https://www.youtube.com/watch?v=XOSUt8Ih3zA&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb>

<https://github.com/features/codespaces>

1. Create Github

    <https://github.com/muhajir29/DEZoomcamp2024>

2. Create codespace

    Open codespace in visual studio code
In code space already python with some package
Docker just install in visual studio code

3. Install Terraform

    <https://developer.hashicorp.com/terraform/install#Linux>

4. Install Jupyter Notebook

    ```python
    pip install jupyter
    ```

5. Install Postgesql and pgadmin with docker
    - Create Network

        ```docker
        docker network create pg-network
        ```

    - Create Volume

        ```docker
        docker volume create --name dtc_postgres_volume_local -d local
        ```

    - Create Docker Postgres

        ```docker
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

    - Create Docker PgAdmin

        ```docker
        docker run -it \
        -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
        -e PGADMIN_DEFAULT_PASSWORD="root" \
        -p 8080:80 \
        --network=pg-network \
        --name pgadmin \
        dpage/pgadmin4
        ```

### Data Ingestion

1. Create Code ingest_data.py
2. Install Package

    ```console
    pip install pandas sqlalchemy psycopg2
    ```

3. Run the code with this command

    ```console
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

1. Create Dockerfile

2. Build image docker file

    format

    ```docker
    docker build -t <image name> .
    ```

    example

    ```docker
    docker build -t ingest_data .
    ```

3. run code with docker 

    ```docker
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

### Set Up PGAdmin and Postgress with docker-compose

before create new docker container and new image, i suggest to prune(remove all) of container and image,with this command

Delete all container

```docker
docker container prune
```

Delete all image

```docker
docker image prune --all
```

1. Create docker-compose.yaml file 
2. Build and run docker-compose

    ```docker
    docker-compose up -d 
    ```

3. if you done, you can shutdown your docker-compose with

    ```docker
    docker-compose down
    ```

### Starting Using Terraform

Terraform Basic:  <https://www.youtube.com/watch?v=Y2ux7gq3Z0o>

1. Create Account GCP

2. Create new file for terraform

    ```console
    mkdir terraform_learning
    cd terraform_learning 
    ```

3. Create service-account with key in .json (credential)

    - download credential in .json key

    - export credential to local

        ```console
        export GOOGLE_CREDENTIALS='path to .json' 
        
        example: 
        export GOOGLE_CREDENTIALS='/workspaces/DEZoomcamp2024/week1/terraform/training-de.json'
        ```

        and make sure with print the variable

        ```console
        echo $GOOGLE_CREDENTIALS
        ```

4. Create file main.tf

    you can see in documentation

    <https://registry.terraform.io/providers/hashicorp/google/latest/docs>

    trying to set up infrasutructure with create GCS (Google Cloud Storage) with Terraform

    <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket>

    ```terraform
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

5. Terraform init

    ```console
    terraform init
    ```

6. Terraform Plan

    ```console
    terraform plan
    ```

7. Terraform Apply

    ```console
    terraform apply
    ```

8. Terraform Destroy

    if already done, you can delete all with:

    ```console
    terraform destroy
    ```

### Terraform Working with Variable

1. Clean credentials set up before

    previously we using variable that save in local with export GOOGLE_CREDENTIALS, now we can clean this variable

    ```console
    unset GOOGLE_CREDENTIALS
    ```

    check, if result empty you are correct

    ```console
    echo $GOOGLE_CREDENTIALS
    ```

    in this section we can try save the credential in variable.tf

2. Create file variable.tf

    for save the value variable for main.tf

    ```terraform
    variable "credentials" {
        description = "My Credentials"
        default = "./<path to json credential.json>"
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
        #Update the below to what you want your dataset to be called
        default     = "training_de_dataset"
    }

    variable "gcs_bucket_name" {
        description = "My Storage Bucket Name"
        #Update the below to a unique bucket name
        default     = "training_de_bucket"
    }

    variable "gcs_storage_class" {
        description = "Bucket Storage Class"
        default     = "STANDARD"
    }

    ```

3. Modify file main.tf

    set up variable from variable.tf and add big query provider

    ```console
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

    resource "google_bigquery_dataset" "demo_dataset" {
        dataset_id = var.bq_dataset_name
        location   = var.location
    }
    ```

4. Implementation Infrastructure

    ```terraform
    terraform plan
    terraform apply
    ```

5. Destroy Infrastructure

    ```terraform
    terraform destroy
    
    ```