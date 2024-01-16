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

