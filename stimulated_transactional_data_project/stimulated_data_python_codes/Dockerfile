FROM apache/airflow:3.0.0

WORKDIR /stimulated_data

COPY requirements.txt /stimulated_data

RUN pip install --no-cache-dir -r /stimulated_data/requirements.txt