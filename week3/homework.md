# Week 3 Homework

ATTENTION: At the end of the submission form, you will be required to include a link to your GitHub repository or other public code-hosting site. This repository should contain your code for solving the homework. If your solution includes code that is not in file format (such as SQL queries or shell commands), please include these directly in the README file of your repository.

<b><u>Important Note:</b></u> <p> For this homework we will be using the 2022 Green Taxi Trip Record Parquet Files from the New York
City Taxi Data found here: </br> <https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page> </br>
If you are using orchestration such as Mage, Airflow or Prefect do not load the data into Big Query using the orchestrator.</br>
Stop with loading the files into a bucket. </br></br>
<u>NOTE:</u> You will need to use the PARQUET option files when creating an External Table</br>

<b>SETUP:</b></br>
Create an external table using the Green Taxi Trip Records Data for 2022. </br>
Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table). </br>
</p>

## Setup all of think

im using mage to input data Green Taxi Trip Record Data for 2022

1. Set up Package

    add pyarrow in requirement.txt file

2. Create block loader

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
        """
        Template for loading data from API
        """

        data_list = []
        for month in range(1, 13):
            month = str(month).zfill(2)
            url = f'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-{month}.parquet'
            data_month = pd.read_parquet(url, engine='pyarrow')
            print(data_month.shape, url)
            data_list.append(data_month)
        data = pd.concat(data_list)
        print("total of data", data.shape)

        return data   

    @test
    def test_output(output, *args) -> None:
        """
        Template code for testing the output of the block.
        """
        assert output is not None, 'The output is undefined'
    ```

3. Create block tranformer

    ```python
    if 'transformer' not in globals():
        from mage_ai.data_preparation.decorators import transformer
    if 'test' not in globals():
        from mage_ai.data_preparation.decorators import test




    def camel_to_snake(name):
        result = []
        for i, char in enumerate(name):
            if name[i].isupper() and name[i-1].islower():
                result.extend(['_', char.lower()])
            else:
                result.append(char.lower())

        return ''.join(result)


    @transformer
    def transform(data, *args, **kwargs):
        print(data.columns)
        # data = data[(data['passenger_count'] != 0) ]
        # data = data[data['trip_distance'] != 0]
        

        data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date


        data.columns = data.columns.map(camel_to_snake)

        print(data.shape)
        # data.head()

        return data

    @test
    def test_output(output, *args) -> None:
        """
        Template code for testing the output of the block.
        """
        assert output is not None, 'The output is undefined'

    ```

4. Create block exporter

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
        table_id = 'orag-big-data.A_test.green_taxi_2022'
        config_path = path.join(get_repo_path(), 'io_config.yaml')
        config_profile = 'dev'

        print(df.shape)
        BigQuery.with_config(ConfigFileLoader(config_path, config_profile)).export(
            df,
            table_id,
            if_exists='replace',  # Specify resolution policy if table name already exists
        )

    ```

## Question 1

Question 1: What is count of records for the 2022 Green Taxi Data??

- 65,623,481
- 840,402 (answer)
- 1,936,423
- 253,647

## Question 2

Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.</br>
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

- 0 MB for the External Table and 6.41MB for the Materialized Table (answer, external table 98 mb)
- 18.82 MB for the External Table and 47.60 MB for the Materialized Table
- 0 MB for the External Table and 0MB for the Materialized Table (answer, because using cache )
- 2.14 MB for the External Table and 0MB for the Materialized Table

## Question 3

How many records have a fare_amount of 0?

- 12,488
- 128,219
- 112
- 1,622 (answer)

## Question 4

What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)

- Cluster on lpep_pickup_datetime Partition by PUlocationID
- Partition by lpep_pickup_datetime  Cluster on PUlocationID
- Partition by lpep_pickup_datetime and Partition by PUlocationID (answer)
- Cluster on by lpep_pickup_datetime and Cluster on PUlocationID

## Question 5

Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime
06/01/2022 and 06/30/2022 (inclusive)</br>

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values? </br>

Choose the answer which most closely matches.</br>

- 22.82 MB for non-partitioned table and 647.87 MB for the partitioned table
- 12.82 MB for non-partitioned table and 1.12 MB for the partitioned table (answer)
- 5.63 MB for non-partitioned table and 0 MB for the partitioned table
- 10.31 MB for non-partitioned table and 10.31 MB for the partitioned table

## Question 6

Where is the data stored in the External Table you created?

- Big Query
- GCP Bucket (answer)
- Big Table
- Container Registry

## Question 7

It is best practice in Big Query to always cluster your data:

- True
- False (answer)

## (Bonus: Not worth points) Question 8

No Points: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

## Submitting the solutions

- Form for submitting: TBD
- You can submit your homework multiple times. In this case, only the last submission will be used.

Deadline: TBD
