import datetime
from datetime import timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from airflow.providers.amazon.aws.transfers.s3_to_redshift import \
    S3ToRedshiftOperator

from utils.stimulated_transactional_data.stimulated_data import \
    (create_synthetic_transactions_table,
     generate_synthetic_transactions,
     load_synthetic_data_to_s3)


default_args = {
    'start_date': datetime.datetime(2025, 8, 1),
    'retries': 2,
    'retry_delay': timedelta(seconds=5),
    'catchup': False
}

dag = DAG(
    dag_id='synthetic_data_dag_s3',
    default_args=default_args,
    schedule='@daily',
    description='A DAG to send synthetic data to S3',
)

# Define the tasks

generate_data = PythonOperator(
        dag=dag,
        python_callable=generate_synthetic_transactions,
        task_id='generate_synthetic_data'
        )

load_data_to_s3 = PythonOperator(
        dag=dag,
        python_callable=load_synthetic_data_to_s3,
        task_id='load_synthetic_data_to_s3'
        )

create_redshift_table = PythonOperator(
        dag=dag,
        python_callable=create_synthetic_transactions_table,
        task_id='create_redshift_table_data'
    )

move_to_redshift = S3ToRedshiftOperator(
        task_id="copy_s3_to_redshift",
        redshift_conn_id="redshift_connection_id",
        s3_bucket="goziestimulateddata",
        s3_key="stimulateddata/*",
        schema="PUBLIC",
        table="synthetic_transactions",
        copy_options=["FORMAT AS PARQUET"],
        method="APPEND",
        aws_conn_id="aws_default",
        dag=dag
    )

generate_data >> load_data_to_s3 >> create_redshift_table >> move_to_redshift
