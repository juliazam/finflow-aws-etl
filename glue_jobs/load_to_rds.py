import os
import io
import psycopg2
from dotenv import load_dotenv
import boto3
import pandas as pd

load_dotenv()
db_name = os.getenv("RDS_DB")
db_user = os.getenv("RDS_DB_USER")
db_pass = os.getenv("RDS_DB_PASS")

access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_region = os.getenv("AWS_DEFAULT_REGION")

try:
    with psycopg2.connect(
        host = "localhost",
        port = "15432",
        database = db_name,
        user = db_user,
        password = db_pass
    ) as connection:
        with connection.cursor() as cursor:

            # Create transactions table
            query = """
            CREATE TABLE IF NOT EXISTS transactions (
                id TEXT PRIMARY KEY,
                amount NUMERIC,
                processed TEXT
            );
            """
            cursor.execute(query)
            connection.commit()
            print("Table 'transactions' was created successfully.")

            # Read processed data from S3 bucket
            s3_client = boto3.client(
                's3',
                endpoint_url = 'http://localhost:4566',
                aws_access_key_id = access_key_id,
                aws_secret_access_key = access_key,
                region_name = aws_region
            )
            bucket_name = 'finflow-processed-data'
            file_key = 'processed_test.csv'

            try:
                # Get object from S3
                response = s3_client.get_object(Bucket=bucket_name, Key=file_key)

                # Get file content
                csv_data = response['Body'].read().decode('utf-8')

                # Create DataFrame from csv
                df = pd.read_csv(io.StringIO(csv_data))
                print(f'File {bucket_name}/{file_key} was read successfully.')

                # Replace NaN to None (for correct insert in SQL)
                df = df.where(pd.notnull(df), None)

                records_to_insert = list(df[['id', 'amount', 'processed']].
                                        itertuples(index=False, name=None))
                print(f"Loading {len(records_to_insert)} rows.")

            except Exception as err:
                print(f"Reading error from S3: {err}")
                records_to_insert = []

            if records_to_insert:
                query = """
                INSERT INTO transactions (id, amount, processed)
                VALUES (%s, %s, %s)
                ON CONFLICT (id) DO NOTHING;
                """

                cursor.executemany(query, records_to_insert)
                connection.commit()

                print(f"Data was inserted successfully. Total rows: {cursor.rowcount}")
except Exception as err:
    print("Error with PostgreSQL connection:", err)
