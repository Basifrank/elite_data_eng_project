import os
from datetime import datetime

import awswrangler as wr
import boto3
import numpy as np
import pandas as pd
from dotenv import load_dotenv
from faker import Faker
from airflow.providers.postgres.hooks.postgres import PostgresHook


def generate_synthetic_transactions():
    """
    Generate synthetic transaction data and return it as a DataFrame.
    Returns:
        pd.DataFrame: DataFrame containing synthetic transaction data.
    """
    fake = Faker()
    num_rows = np.random.randint(500_000, 1_000_001)

    # Vectorized generation
    transaction_ids = [fake.uuid4() for _ in range(num_rows)]
    customer_ids = np.random.randint(10000, 100000, size=num_rows)
    amounts = np.round(np.random.uniform(5, 5000, size=num_rows), 2)
    types = np.random.choice(['purchase', 'refund'], size=num_rows)

    df = pd.DataFrame({
        'transaction_id': transaction_ids,
        'customer_id': customer_ids,
        'amount': amounts,
        'type': types
    })
    return df


def load_synthetic_data_to_s3():
    """
    This function generates synthetic transaction data
    and writes it to an S3 bucket.
    It uses the AWS credentials and region specified in environment variables.
    It also uses the awswrangler library to write the
    DataFrame in Parquet format.
    Returns:
        write data to s3 bucket.
    """
    # Get the current date and time for the file name
    df = generate_synthetic_transactions()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    load_dotenv()
    session = boto3.Session(
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=os.getenv("AWS_REGION")
    )
    raw_s3_bucket = "goziestimulateddata"
    raw_path_dir = "stimulateddata"
    path = f"s3://{raw_s3_bucket}/{raw_path_dir}" + f"/{now}"
    wr.s3.to_parquet(
        df=df,
        path=path,
        dataset=True,
        mode="append",
        boto3_session=session)


def create_synthetic_transactions_table():
    hook = PostgresHook(postgres_conn_id='redshift_connection_id')
    conn = hook.get_conn()
    conn.autocommit = True
    cursor = conn.cursor()
    sql = """
    CREATE TABLE IF NOT EXISTS synthetic_transactions (
        transaction_id VARCHAR(256),
        customer_id VARCHAR(256),
        amount DECIMAL(18, 2),
        type TEXT
    );
    """
    cursor.execute(sql)
    cursor.close()
    conn.close()
