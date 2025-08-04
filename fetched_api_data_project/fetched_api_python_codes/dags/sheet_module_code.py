import os

import gspread
import pandas as pd
from airflow.providers.postgres.hooks.postgres import PostgresHook
from dotenv import load_dotenv
from sqlalchemy import create_engine


def get_google_sheet_data_public():
    """
    Fetches data from a Google Sheet and returns it as a pandas DataFrame.

    Args:
       None

    Returns:
        pd.DataFrame: DataFrame containing the sheet data.
    """
    # load_dotenv() Load environment variables from .env file

    load_dotenv()
    api_key = os.getenv("GOOGLE_API_KEY")
    worksheet_id = os.getenv("GOOGLE_WORKBOOK_ID")
    sheet_id = os.getenv("GOOGLE_SHEET_ID")

    # Authenticate with the Google Sheets API using the API key
    public_access_token = gspread.api_key(api_key)
    public_access = public_access_token.open_by_key(worksheet_id)
    worksheet = public_access.get_worksheet_by_id(sheet_id)
    data = worksheet.get_all_records()
    df = pd.DataFrame(data)
    return df


def update_column_names():
    """
    This function fetches data from a Google Sheet function,
    processes the column names by stripping spaces,
    converting them to lowercase, and replacing spaces with underscores.
    The updated DataFrame is then returned.
    Args:
        None
    Returns:
        df: df with updated names.
    """
    df = get_google_sheet_data_public()
    strip_space_lowecase = [col.strip().lower() for col in df.columns.tolist()]
    rename_cols = [col.replace(" ", "_") for col in strip_space_lowecase]
    df.columns = rename_cols
    return df


def create_table_in_rds_with_hook():
    hook = PostgresHook(postgres_conn_id='postgres_connection_id')
    sql = """
    CREATE TABLE IF NOT EXISTS my_rds_table (
        first_name TEXT,
        last_name TEXT,
        state_of_origin TEXT
    );
    """
    hook.run(sql)


def write_dataframe_to_rds_postgres(if_exists: str = 'append'):
    """
    Writes a Pandas DataFrame to a PostgreSQL table in an Amazon RDS instance.

    """
    load_dotenv()
    dataframe = update_column_names()
    table_name = "my_rds_table"
    db_host = os.getenv("db_host")
    db_port = 5432
    db_name = os.getenv("db_name")
    db_user = os.getenv("db_user")
    db_password = os.getenv("db_password")

    try:
        # Create the database engine
        engine = create_engine(
            f"""postgresql+psycopg2://{db_user}:{db_password}@\
                {db_host}:{db_port}/{db_name}""")

        # Write the DataFrame to the SQL table
        dataframe.to_sql(name=table_name,
                         con=engine, if_exists=if_exists, index=False)
    except Exception as e:
        print(f"Error writing DataFrame to RDS PostgreSQL: {e}")


def create_table_redshift():
    hook = PostgresHook(postgres_conn_id='my-redshift-cluster')
    conn = hook.get_conn()
    conn.autocommit = True
    cursor = conn.cursor()
    sql = """
    CREATE TABLE IF NOT EXISTS rds_api_table (
        first_name TEXT,
        last_name TEXT,
        state_of_origin TEXT
    );
    """
    cursor.execute(sql)
    cursor.close()
    conn.close()
