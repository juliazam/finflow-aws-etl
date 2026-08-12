''' Reads raw data, adds label and saves into processed data '''
import os
import csv
import io
import boto3

# NOTE: default_arguments from aws_glue_job (Terraform) are not passed to
# subprocess when running in pythonshell on Ministack—a known emulator limitation.
# The values ​​are hardcoded as pipeline constants.
RAW_BUCKET = 'finflow-raw-data'
PROCESSED_BUCKET = 'finflow-processed-data'
SOURCE_KEY = 'test.csv'

s3 = boto3.client(
    's3',
    endpoint_url = 'http://ministack:4566',
    aws_access_key_id='test',
    aws_secret_access_key='test',
    region_name='ap-southeast-1'
)

obj = s3.get_object(Bucket=RAW_BUCKET, Key=SOURCE_KEY)
raw_content = obj['Body'].read().decode('utf-8')

reader = csv.DictReader(io.StringIO(raw_content))
rows = list(reader)
for row in rows:
    row['processed'] = 'true'

output = io.StringIO()
writer = csv.DictWriter(output, fieldnames=reader.fieldnames + ['processed'])
writer.writeheader()
writer.writerows(rows)

s3.put_object(
    Bucket=PROCESSED_BUCKET,
    Key=f'processed_{SOURCE_KEY}',
    Body=output.getvalue()
)
