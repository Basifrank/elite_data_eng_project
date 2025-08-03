FROM apache/airflow:3.0.0

WORKDIR /google_rds_data

COPY requirements.txt /google_rds_data

RUN pip install --no-cache-dir -r /google_rds_data/requirements.txt