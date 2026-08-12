''' Reads raw data, adds label and saves into processed data '''
import sys
import csv
import io
import boto3
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ['RAW_BUCKET', 'PROCESSED_BUCKET', 'SOURCE_KEY'])

s3 = boto3.client('s3', endpoint_url='http://ministack:4566')

obj = s3.get_object(Bucket=args['RAW_BUCKET'], Key=args['SOURCE_KEY'])
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
    Bucket=args['PROCESSED_BUCKET'],
    Key=f"processed_{args['SOURCE_KEY']}",
    Body=output.getvalue()
)

print(f"Processed {len(rows)} rows from {args['SOURCE_KEY']}")
