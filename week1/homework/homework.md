# Module 1 Homework

## Docker & SQL

In this homework we'll prepare the environment
and practice with Docker and SQL

## Question 1. Knowing docker tags

Run the command to get information on Docker

```docker --help```

Now run the command to get help on the "docker build" command:

```docker build --help```

Do the same for "docker run".

Which tag has the following text? - *Automatically remove the container when it exits*

```console
pip install jupyter
```

- `--delete`
- `--rc`
- `--rmc`
- `--rm`

Answer

Command

```docker run --help```

Result

`--rm : Automatically remove the container when it exits`

## Question 2. Understanding docker first run

Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash.
Now check the python modules that are installed ( use ```pip list``` ).

What is version of the package *wheel* ?

- 0.42.0
- 1.0.0
- 23.0.1
- 58.1.0

Answer

Command

```docker run -it --entrypoint /bin/bash python:3.9```

after bash open

```pip list```

Result

`wheel      0.42.0`

## Prepare Postgres

Run Postgres and load data as shown in the videos
We'll use the green taxi trips from September 2019:

```wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz```

You will also need the dataset with zones:

```wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv```

Download this data and put it into Postgres (with jupyter notebooks or with a pipeline)

## How to insert data green trip data

```wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz```

```console
docker-composer up -d
```

```console
URL = "<https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz>"
```

modify the code in file ingest_data.py
change column name

**tpep_pickup_datetime** --> **lpep_pickup_datetime**

**lpep_dropoff_datetime** --> **lpep_dropoff_datetime**

```console
python ingest_data.py \
--user=root \
--password=root \
--host=localhost \
--port=5432 \
--db=ny_taxi \
--table_name=green_taxi_trips \
--url=${URL}
```

to connect your pg-admin to database:

host = using container name database

## How to insert data zone lookup

1. Download data

    ```console
    wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv
    ```

2. open jupyter notebook

    ```console
    jupyter notebook
    ```

3. Create Jupyter data_insert.ipynb and run

## Question 3. Count records

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18.

Remember that `lpep_pickup_datetime` and `lpep_dropoff_datetime` columns are in the format timestamp (date and hour+min+sec) and not in date.

- 15767
- 15612
- 15859
- 89009

answer

Query

```sql
SELECT count(*)
FROM public.green_taxi_trips
where DATE(lpep_pickup_datetime) = '2019-09-18' 
AND DATE(lpep_dropoff_datetime) = '2019-09-18';
```

result:

15612

## Question 4. Largest trip for each day

Which was the pick up day with the largest trip distance
Use the pick up time for your calculations.

- 2019-09-18
- 2019-09-16
- 2019-09-26
- 2019-09-21

query

```sql
select date(lpep_pickup_datetime), sum(trip_distance) from public.green_taxi_trips
group by 1 
order by 2 desc;
```

result

20190926

## Question 5. Three biggest pick up Boroughs

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

- "Brooklyn" "Manhattan" "Queens"
- "Bronx" "Brooklyn" "Manhattan"
- "Bronx" "Manhattan" "Queens"
- "Brooklyn" "Queens" "Staten Island"

answer

```sql
select f."Borough", SUM(f.total_amount) from
 (select g."PULocationID", g.total_amount, g.lpep_pickup_datetime, zon."Borough"
        from public.green_taxi_trips as g
        left join public.taxi_zone_lookup as zon
        on g."PULocationID" = zon."LocationID"
        where date(lpep_pickup_datetime) = '2019-09-18') f
group by 1 
order by 2 desc;
```

result

- "Brooklyn" "Manhattan" "Queens"

## Question 6. Largest tip

For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Note: it's not a typo, it's `tip` , not `trip`

- Central Park
- Jamaica
- JFK Airport
- Long Island City/Queens Plaza

answer

```sql
select fnl."Zone", max(fnl."tip_amount") from
(select du.*, zuu."Zone" from
    (select g."DOLocationID", g."tip_amount" 
        from public.green_taxi_trips as g
    left join public.taxi_zone_lookup as zu
    on g."PULocationID" = zu."LocationID"
    where EXTRACT(MONTH FROM g.lpep_pickup_datetime) = 9 
        and zu."Zone" = 'Astoria') du
left join 
    public.taxi_zone_lookup as zuu
on du."DOLocationID" = zuu."LocationID") fnl
group by 1 
order by 2 desc;
```

result

"JFK Airport"

## Terraform

In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform.
Copy the files from the course repo
[here](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/01-docker-terraform/1_terraform_gcp/terraform) to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.

## Question 7. Creating Resources

After updating the main.tf and variable.tf files run:

```console
terraform apply
```

Paste the output of this command into the homework submission form.

```console
@muhajir29 ➜ /workspaces/DEZoomcamp2024/week1/terraform (main) $ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.demo_dataset will be created
  + resource "google_bigquery_dataset" "demo_dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "training_de_dataset"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = (known after apply)
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "US"
      + max_time_travel_hours      = (known after apply)
      + project                    = "<my project id>"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = (known after apply)
    }

  # google_storage_bucket.demo-bucket will be created
  + resource "google_storage_bucket" "demo-bucket" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "US"
      + name                        = "training_de_bucket"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "AbortIncompleteMultipartUpload"
            }
          + condition {
              + age                   = 1
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.demo_dataset: Creating...
google_storage_bucket.demo-bucket: Creating...
google_bigquery_dataset.demo_dataset: Creation complete after 1s [id=projects/<my project id>/datasets/training_de_dataset]
google_storage_bucket.demo-bucket: Creation complete after 2s [id=training_de_bucket]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

```

## Submitting the solutions

- Form for submitting: <https://courses.datatalks.club/de-zoomcamp-2024/homework/hw01>
- You can submit your homework multiple times. In this case, only the last submission will be used.

Deadline: 29 January, 23:00 CET
