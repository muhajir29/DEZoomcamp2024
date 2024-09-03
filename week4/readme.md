
# Installation

## 1. create env variable

```bash
python -m venv env_dbt
```

## 2. activete env variable

```bash
source env_dbt/bin/activate
```

## 3. install dbt core + dbt-postgres adapter

```bash
python -m pip install dbt-core dbt-postgres
```

## 4. clone dbt starter project

```bash
git clone https://github.com/dbt-labs/dbt-starter-project.git dbt_project
cd dbt_project 
```

## 5. set up profile.yml dbt

create or open : ~/.dbt/profiles.yml

i want set up postgresql adapter so add code like that

```yml
        my_postgres_profile:
        outputs:
            dev:
            type: postgres
            host: localhost
            user: postgres
            password: postgres
            port: 5444
            dbname: postgres
            schema: staging
            threads: 4
            timeout_seconds: 300
        target: dev
```

## 6. set up dbt_project.yml

in dbt_project repository edit file
from

```yml
profile: 'default'
```

to, base on your profiles.yml

```yml
profile: 'my_postgres_profile'
```

## 7. initiation dbt

```bash
dbt init 
```

and check all of connection already passed

```bash
dbt debug 
```

# Create Simple model in DBT

## 1. Preparatoin

    remove model example in /models/example 

    rm -rf models/example/

    create new folder in /models with name staging 

    mkdir models/staging/
    
    create schema.yaml in this folder, like data source, model etc

    touch models/schema.yml

    add just file dbt_project.yml in section model with this . 
    ``` code
    models:
        my_new_project:
            staging:
            +materialized: view
    ```


## 2. Set up schema model in folder staging

    add this code 

    from this example 
    https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/04-analytics-engineering/taxi_rides_ny/models/staging/schema.yml 

    adjust by you needed 


    in this, we set up schema our data source, 

    create simpel shema.yaml 
    ```yml
        version: 2

        sources:
        - name: staging
            database: postgres  # Specify the PostgreSQL database name
            schema: staging

            tables:
            - name: green_tripdata
            - name: yellow_tripdata

        models:
        - name: stg_green_tripdata
            description: >
            Trip made by green taxis, also known as boro taxis and street-hail liveries.
            Green taxis may respond to street hails, but only in the areas indicated in green on the
            map (i.e. above W 110 St/E 96th St in Manhattan and in the boroughs).
            The records were collected and provided to the NYC Taxi and Limousine Commission (TLC) by
            technology service providers. 

        - name: stg_yellow_tripdata
            description: > 
            Trips made by New York City's iconic yellow taxis. 
            Yellow taxis are the only vehicles permitted to respond to a street hail from a passenger in all five
            boroughs. They may also be hailed using an e-hail app like Curb or Arro.
            The records were collected and provided to the NYC Taxi and Limousine Commission (TLC) by
            technology service providers. 

        
    ````

## 4. add model stg_green_trip_data.sql and stg_yellow_trip_data.sql

stg_green_trip_data.sql

```sql
    {{
        config(
            materialized='view'
        )
    }}

    with tripdata as 
    (
    select *,
        row_number() over(partition by vendorid, lpep_pickup_datetime) as rn
    from {{ source('staging','green_tripdata') }}
    where vendorid is not null 
    )

    select * from tripdata
```

stg_yellow_trip_data.sql

```sql

{{ config(materialized='view') }}
 
with tripdata as 
(
  select *,
    row_number() over(partition by vendorid, tpep_pickup_datetime) as rn
  from {{ source('staging','yellow_tripdata') }}
  where vendorid is not null 
)
select * from tripdata

```

## 5. Run the model 

dbt build --models stg_yellow_tripdata

dbt build --models stg_green_tripdata


# add Package in model 

## 1. Craete file package.yml

fill file with package, like this 

packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  - package: dbt-labs/codegen
    version: 0.12.1

## 2. install package 

dbt deps

## 3. Write package in code 

stg_green_tripdata
```sql
{{
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *,
    row_number() over(partition by vendorid, lpep_pickup_datetime) as rn
  from {{ source('staging','green_tripdata') }}
  where vendorid is not null 
)

select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    {{ dbt.safe_cast("vendorid", api.Column.translate_type("integer")) }} as vendorid,
    {{ dbt.safe_cast("ratecodeid", api.Column.translate_type("integer")) }} as ratecodeid,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
    
    -- timestamps
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    {{ dbt.safe_cast("passenger_count", api.Column.translate_type("integer")) }} as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    {{ dbt.safe_cast("trip_type", api.Column.translate_type("integer")) }} as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(ehail_fee as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    coalesce({{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }},0) as payment_type
from tripdata
where rn = 1

and that build the code 
```

dbt build --select stg_green_tripdat 


### add code in 
stg_yellow_tripdata 

```sql
{{ config(materialized='view') }}
 
with tripdata as 
(
  select *,
    row_number() over(partition by vendorid, tpep_pickup_datetime) as rn
  from {{ source('staging','yellow_tripdata') }}
  where vendorid is not null 
)
select
   -- identifiers
    {{ dbt_utils.generate_surrogate_key(['vendorid', 'tpep_pickup_datetime']) }} as tripid,    
    {{ dbt.safe_cast("vendorid", api.Column.translate_type("integer")) }} as vendorid,
    {{ dbt.safe_cast("ratecodeid", api.Column.translate_type("integer")) }} as ratecodeid,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,

    -- timestamps
    cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    {{ dbt.safe_cast("passenger_count", api.Column.translate_type("integer")) }} as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    -- yellow cabs are always street-hail
    1 as trip_type,
    
    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(0 as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    coalesce({{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }},0) as payment_type
    
from tripdata
where rn = 1

```


### add variable in every code above

add this code in below code 

```sql
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
```

### Build model with variable 

dbt build --select <model_name> --vars '{'is_test_run': 'false'}'

## 4 Build Function
for buid function in dbt, we can add function in mscros file 

1. Create File  in sql 
in this case 
get_payment_type_description.sql 

2. add the code 

```sql
{#
    This macro returns the description of the payment_type 
#}

{% macro get_payment_type_description(payment_type) -%}

    case {{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }}  
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'EMPTY'
    end

{%- endmacro %}
```

3. create macros_properties.yml

4. call the function in model 

example in stg_yellow_tripdata adn stg_green_tripdata 

im add this code query within select function
```sql 
{{ get_payment_type_description("payment_type") }} as payment_type_description
```


## 5.Create New model  code model 
this model to combine result stg_green_tripdata and stg_yellow_tripdata 

create folder code in folder models

## Create Model Core

this model for process result from staging model and other

### 1. create schema.yml in folder core 

  ```yml
  version: 2

  models:
    - name: dim_zones
    - name: dm_monthly_zone_revenue
    - name: fact_trips
  ```

### 2. add seed 

2. create .yml in folder data 
in my case 
seeds_properties.yml 

3. set up set config seeds in dbt_project.yml 
in my case 

seeds: 
    my_new_project:
        taxi_zone_lookup:
            +column_types:
                locationid: numeric

4. compile seed 
dbt seed

### 2. Create every model 
craete model 
build 1 by 1 
dim_zones.sql
fact_trips.sql 
dm_monthly_zone_revenue.sql 


## add Documentation and testing 

after complete craete model end to end
we need to create documentation 

1. install package 
codegen 
this is for generate automation documentation every model 

2. create documentation to paste into your schema.yml

a. for staging folder
dbt run-operation generate_model_yaml --args '{"model_names": ["stg_green_tripdata", "stg_yellow_tripdata"]}'

copy the result into schema.yml in staging folder

b. for code folder

3. add description manualy in filde schema.yml 

4. add variable for value of testing
in this case i need create variable to check accepted value 
so first step add variable to dbt_project.yml

vars:
  payment_type_values: [1, 2, 3, 4, 5, 6]

this variable will be call in testing 

5. add testing in shema 

in my case 
i add testing in model 
in model stg_green_tripdata column tripid
tests: 
  - unique:
      severity: warn
  - not_null:
      severity: warn

and other 
you can see the spesifik in shema.yml 

5. try run all model 
dbt build

6. generate documentation 

dbt docs generate 


7. run documentation in webserve 

dbt docs serve 











