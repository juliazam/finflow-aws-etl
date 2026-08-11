''' Raw data file validation '''
def validate_raw_file(event, context):
    ''' Validate raw file '''
    print(f"Received event: {event}")
    return {"status": "ok"}
