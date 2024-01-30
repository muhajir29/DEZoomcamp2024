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

### Create Pipeline

1. load_ny_taxi (Data loader)

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
input credential 



