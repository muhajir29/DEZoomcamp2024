# Week 2

## [Installation Mage](mage-zoomcamp/Installation.md)

## ETL to Postgres

### Configuration Postgres

1. Open file in oi_config.yaml in mage

    <http://127.0.0.1:6789/files>

2. add configuration postgress in file oi_conig.yaml, with profile dev (profile new)

    ```yaml
    dev: 
    POSTGRES_CONNECT_TIMEOUT: 10
    POSTGRES_DBNAME: "{{ env_var('POSTGRES_DBNAME')}}"
    POSTGRES_SCHEMA: "{{ env_var('POSTGRES_SCHEMA')}}"
    POSTGRES_USER: "{{ env_var('POSTGRES_USER')}}"
    POSTGRES_PASSWORD: "{{ env_var('POSTGRES_PASSWORD')}}"
    POSTGRES_HOST: "{{ env_var('POSTGRES_HOST')}}"
    POSTGRES_PORT: "{{ env_var('POSTGRES_PORT')}}"
    ```

### Load Data to Postgres

1. load_from_api (Data loader)

    Data Loader --> Python --> URL
    and modify until like this

    ```python
    import io
    import pandas as pd
    import requests
    if 'data_loader' not in globals():
        from mage_ai.data_preparation.decorators import data_loader
    if 'test' not in globals():
        from mage_ai.data_preparation.decorators import test

    @data_loader
    def load_data_from_api(*args, **kwargs):
        url = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz'
        
        taxi_dtypes = {
                        'VendorID': pd.Int64Dtype(),
                        'passenger_count': pd.Int64Dtype(),
                        'trip_distance': float,
                        'RatecodeID':pd.Int64Dtype(),
                        'store_and_fwd_flag':str,
                        'PULocationID':pd.Int64Dtype(),
                        'DOLocationID':pd.Int64Dtype(),
                        'payment_type': pd.Int64Dtype(),
                        'fare_amount': float,
                        'extra':float,
                        'mta_tax':float,
                        'tip_amount':float,
                        'tolls_amount':float,
                        'improvement_surcharge':float,
                        'total_amount':float,
                        'congestion_surcharge':float
                    }

        # native date parsing 
        parse_dates = ['tpep_pickup_datetime', 'tpep_dropoff_datetime']

        return pd.read_csv(
            url, sep=',', compression='gzip', dtype=taxi_dtypes, parse_dates=parse_dates
            )


    @test
    def test_output(output, *args) -> None:
        """
        Template code for testing the output of the block.
        """
        assert output is not None, 'The output is undefined'
        
    ```

2. clean_data (transformer)
    transformer --> python --> blank 

    ```python
    if 'transformer' not in globals():
        from mage_ai.data_preparation.decorators import transformer
    if 'test' not in globals():
        from mage_ai.data_preparation.decorators import test


    @transformer
    def transform(data, *args, **kwargs):
        """
        Template code for a transformer block.

        Add more parameters to this function if this block has multiple parent blocks.
        There should be one parameter for each output variable from each parent block.

        Args:
            data: The output from the upstream parent block
            args: The output from any additional upstream blocks (if applicable)

        Returns:
            Anything (e.g. data frame, dictionary, array, int, str, etc.)
        """
        # Specify your transformation logic here

        return data


    @test
    def test_output(output, *args) -> None:
        """
        Template code for testing the output of the block.
        """
        assert output is not None, 'The output is undefined'
    ```

3. export_portgers (Data Exporter)
    Data Exporter --> python --> Postgres

    ```python
    from mage_ai.settings.repo import get_repo_path
    from mage_ai.io.config import ConfigFileLoader
    from mage_ai.io.postgres import Postgres
    from pandas import DataFrame
    from os import path

    if 'data_exporter' not in globals():
        from mage_ai.data_preparation.decorators import data_exporter


    @data_exporter
    def export_data_to_postgres(df: DataFrame, **kwargs) -> None:

        schema_name = 'ny_taxi'  # Specify the name of the schema to export data to
        table_name = 'yellow_cab_data'  # Specify the name of the table to export data to
        config_path = path.join(get_repo_path(), 'io_config.yaml')
        config_profile = 'dev'

        with Postgres.with_config(ConfigFileLoader(config_path, config_profile)) as loader:
            loader.export(
                df,
                schema_name,
                table_name,
                index=False,  # Specifies whether to include index in exported table
                if_exists='replace',  # Specify resolution policy if table name already exists
            )

    ```

4. load_ny_taxi (data loader)

```sql
select * from ny_taxi.yellow_cab_data limit 20
```

## ETL to GCS

### Configuration GCP

1. Create credential in .json file in GCP

2. open oi_config.yaml

    input credential in bellow

    GOOGLE_SERVICE_ACC_KEY_FILEPATH: "/home/src/training-de.json"
    GOOGLE_LOCATION: US

3. and testing with load data from GCS

    Data Loader --> Python --> Google Cloud Storage

    ```python
    from mage_ai.settings.repo import get_repo_path
    from mage_ai.io.config import ConfigFileLoader
    from mage_ai.io.google_cloud_storage import GoogleCloudStorage
    from os import path
    if 'data_loader' not in globals():
        from mage_ai.data_preparation.decorators import data_loader
    if 'test' not in globals():
        from mage_ai.data_preparation.decorators import test


    @data_loader
    def load_from_google_cloud_storage(*args, **kwargs):
        """
        Template for loading data from a Google Cloud Storage bucket.
        Specify your configuration settings in 'io_config.yaml'.

        Docs: https://docs.mage.ai/design/data-loading#googlecloudstorage
        """
        config_path = path.join(get_repo_path(), 'io_config.yaml')
        config_profile = 'dev'

        bucket_name = 'a_testing'
        object_key = 'titanic_clean.csv'

        return GoogleCloudStorage.with_config(ConfigFileLoader(config_path, config_profile)).load(
            bucket_name,
            object_key,
        )


    @test
    def test_output(output, *args) -> None:
        """
        Template code for testing the output of the block.
        """
        assert output is not None, 'The output is undefined'

    ```

### Load Data to GCS

1. Craete new pipeline

2. Using previous block

    - to read data_loaders\load_from_api.py
    - clean data transformer\clean_data.py

3. write code export data to gcs

    ```python
    from mage_ai.settings.repo import get_repo_path
    from mage_ai.io.config import ConfigFileLoader
    from mage_ai.io.google_cloud_storage import GoogleCloudStorage
    from pandas import DataFrame
    from os import path

    if 'data_exporter' not in globals():
        from mage_ai.data_preparation.decorators import data_exporter


    @data_exporter
    def export_data_to_google_cloud_storage(df: DataFrame, **kwargs) -> None:
        """
        Template for exporting data to a Google Cloud Storage bucket.
        Specify your configuration settings in 'io_config.yaml'.

        Docs: https://docs.mage.ai/design/data-loading#googlecloudstorage
        """
        config_path = path.join(get_repo_path(), 'io_config.yaml')
        config_profile = 'dev'

        bucket_name = 'a_testing'
        object_key = 'ny_taxi_data.parquet'

        GoogleCloudStorage.with_config(ConfigFileLoader(config_path, config_profile)).export(
            df,
            bucket_name,
            object_key,
        )

    ```

4. Write code export to GCS with partition

    ```python
    import pyarrow as pa
    import pyarrow.parquet as pq
    import os


    if 'data_exporter' not in globals():
        from mage_ai.data_preparation.decorators import data_exporter

    # setting env 

    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/home/src/training-de.json'

    project_id = 'orag-big-data'
    bucket_name = 'a_testing'
    table_name = 'nyc_taxi_data'

    root_path = f"{bucket_name}/{table_name}"


    @data_exporter
    def export_data(data, *args, **kwargs):
        print(data.shape)
        data['tpep_pickup_datetime'] = data['tpep_pickup_datetime'].dt.date

        table = pa.Table.from_pandas(data)

        gcs = pa.fs.GcsFileSystem()
        pq.write_to_dataset(
            table,
            root_path=root_path, 
            partition_cols=['tpep_pickup_datetime'], 
            filesystem=gcs
        )
    ```

    and set up the parent block to clean_data (tranformer)

## ETL To BigQuery

1. Create new pipeline
2. using block data_loaders/load_from_api.py
3. create code to tranform

    ```python
    if 'transformer' not in globals():
        from mage_ai.data_preparation.decorators import transformer
    if 'test' not in globals():
        from mage_ai.data_preparation.decorators import test


    @transformer
    def transform(data, *args, **kwargs):

        data.colums = (data.columns.str.replace(' ','_').str.lower())

        return data


    @test
    def test_output(output, *args) -> None:
        """
        Template code for testing the output of the block.
        """
        assert output is not None, 'The output is undefined'
    ```

4. write code to export to big query
data_exporters --> Python --> Big Query

    ```python
    from mage_ai.settings.repo import get_repo_path
    from mage_ai.io.bigquery import BigQuery
    from mage_ai.io.config import ConfigFileLoader
    from pandas import DataFrame
    from os import path

    if 'data_exporter' not in globals():
        from mage_ai.data_preparation.decorators import data_exporter


    @data_exporter
    def export_data_to_big_query(df: DataFrame, **kwargs) -> None:
        """
        Template for exporting data to a BigQuery warehouse.
        Specify your configuration settings in 'io_config.yaml'.

        Docs: https://docs.mage.ai/design/data-loading#bigquery
        """
        table_id = 'orag-big-data.A_test.ny_taxi'
        config_path = path.join(get_repo_path(), 'io_config.yaml')
        config_profile = 'dev'

        print(df.shape)
        BigQuery.with_config(ConfigFileLoader(config_path, config_profile)).export(
            df,
            table_id,
            if_exists='replace',  # Specify resolution policy if table name already exists
        )

    ```

    noted : i have some error because region different, so i need re-adjust location from US to northamerica-northeast1

    ```console
    GOOGLE_LOCATION: northamerica-northeast1
    ```

5. Create Schedule

    a. Go to trigger and create schduler daily

    <http://127.0.0.1:6789/pipelines/charismatic_cloud/triggers>

## Deploy Mage with Terraform in GCP

In this section, we'll cover deploying Mage using Terraform and Google Cloud. This section is optional— it's not *necessary* to learn Mage, but it might be helpful if you're interested in creating a fully deployed project. If you're using Mage in your final project, you'll need to deploy it to the cloud.

Videos

### [Deployment Prerequisites](https://www.youtube.com/watch?v=zAwAX5sxqsg&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb)

1. Terraform

2. gcloud cli

3. Google Cloud Permissions

4. Mage Terraform templates

### [Google Cloud Permissions](https://www.youtube.com/watch?v=O_H7DCmq2rA&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb)

Create service account 

### [Deploying to Google Cloud - Part 1](https://www.youtube.com/watch?v=9A872B5hb_0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb)



[Mage Terraform Templates](https://github.com/mage-ai/mage-ai-terraform-templates)

- [Installing Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Installing `gcloud` CLI](https://cloud.google.com/sdk/docs/install)

Additional Mage Guide

- [Terraform](https://docs.mage.ai/production/deploying-to-cloud/using-terraform)
- [Deploying to GCP with Terraform](https://docs.mage.ai/production/deploying-to-cloud/gcp/setup)

