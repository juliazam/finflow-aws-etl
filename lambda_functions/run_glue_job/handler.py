''' Glue Job handler '''
from time import sleep
import boto3

class GlueJobFailureError(Exception):
    """ Exception for AWS Glue Job """

def run_glue_job(event, context):
    ''' Invode Glue Job with JobName'''
    # Get job name
    job_name = event.get('JobName')

    # Create glue job
    glue = boto3.client(
        'glue',
        endpoint_url='http://ministack:4566',
        aws_access_key_id='test',
        aws_secret_access_key='test',
        region_name='ap-southeast-1'
    )

    # Start glue job
    response = glue.start_job_run(JobName=job_name)
    run_id = response['JobRunId']

    terminal_statuses = ['SUCCEEDED', 'FAILED', 'STOPPED', 'TIMEOUT']

    while True:
        status_response = glue.get_job_run(JobName=job_name, RunId=run_id)
        current_state = status_response['JobRun']['JobRunState']

        if current_state in terminal_statuses:
            break

        sleep(2)

    if current_state == 'SUCCEEDED':
        return {
            'status': current_state,
            'JobName': job_name,
            'JobRunId': run_id,
        }

    raise GlueJobFailureError(
        f"Glue Job {job_name} failed with status: {current_state}. RunId: {run_id}")
