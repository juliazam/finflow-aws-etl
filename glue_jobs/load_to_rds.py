''' Reads processed data and loads into RDS '''
import io
import psycopg2
import boto3
import pandas as pd

DB_HOST = 'ministack'
DB_PORT = "5432"
DB_NAME = "finflow"
DB_USER = "admin"
DB_PASS = "Hla0mqO1l"

ACCESS_KEY_ID = "test"
ACCESS_KEY = "test"
AWS_REGION = "ap-southeast-1"


try:
    with psycopg2.connect(
        host = DB_HOST,
        port = DB_PORT,
        database = DB_NAME,
        user = DB_USER,
        password = DB_PASS
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
                endpoint_url = 'http://ministack:4566',
                aws_access_key_id = ACCESS_KEY_ID,
                aws_secret_access_key = ACCESS_KEY,
                region_name = AWS_REGION
            )
            BUCKET_NAME = 'finflow-processed-data'
            FILE_KEY = 'processed_test.csv'

            try:
                # Get object from S3
                response = s3_client.get_object(Bucket=BUCKET_NAME, Key=FILE_KEY)

                # Get file content
                csv_data = response['Body'].read().decode('utf-8')

                # Create DataFrame from csv
                df = pd.read_csv(io.StringIO(csv_data))
                print(f'File {BUCKET_NAME}/{FILE_KEY} was read successfully.')

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
