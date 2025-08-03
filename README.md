# Elite_data_eng_projects
Projects to stimulate transaction and API data, move to s3 and copy to redshift.

## stimulate and move transactional Data (Project A)
1.	Simulate transaction dataset between 500000 to 1 million daily
2.	Design the code to always run daily
3.	Write to s3
4.	Use airflow copy command to move the data from s3 to redshift

## Fetch API Data and Load to Redshift (Project B)
1.	Fetch data from an API
2.	Setup a RDS instance
3.	Use airflow to move your data from the API to the RDS instance
3.	Then setup airbyte to connect to the rds instance and load the data on Redshift
