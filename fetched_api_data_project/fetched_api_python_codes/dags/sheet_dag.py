import datetime
from datetime import timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from sheet_module_code import (create_table_in_rds_with_hook,
                               get_google_sheet_data_public,
                               update_column_names,
                               write_dataframe_to_rds_postgres,
                               create_table_redshift)

# Default arguments for the DAG
default_args = {
    'start_date': datetime.datetime(2023, 10, 1),
    'retries': 2,
    'retry_delay': timedelta(seconds=5),
}

dag = DAG(
    dag_id='google_sheet_dag_rds',
    default_args=default_args,
    schedule='@daily',
    description='A DAG to send google_sheet data to S3',
)


# Define the tasks
extract_data = PythonOperator(
        dag=dag,
        python_callable=get_google_sheet_data_public,
        task_id='get_google_sheet_data'
)

transform_data = PythonOperator(
        dag=dag,
        python_callable=update_column_names,
        task_id='update_column_names'
)

create_table_rds = PythonOperator(
        dag=dag,
        python_callable=create_table_in_rds_with_hook,
        task_id='create_table_in_rds'
)

write_data_rds = PythonOperator(
        dag=dag,
        python_callable=write_dataframe_to_rds_postgres,
        task_id='write_data_to_rds'
)

create_table_in_redshift = PythonOperator(
        dag=dag,    
        python_callable=create_table_redshift,
        task_id='create_table_in_redshift'
)

extract_data >> transform_data >> create_table_rds >> write_data_rds >> create_table_in_redshift
