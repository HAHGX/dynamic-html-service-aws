import os
import boto3

def lambda_handler(event, context):
    ssm = boto3.client('ssm')
    param_name = os.environ.get('DYNAMIC_STRING_PARAM_NAME', '/dynamic-html-service/dynamic-string')
    response = ssm.get_parameter(Name=param_name)
    dynamic_string = response['Parameter']['Value']
    html = f"""
    <html>
      <head><title>Dynamic HTML</title></head>
      <body>
        <h1>The saved string is {dynamic_string}</h1>
      </body>
    </html>
    """
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'text/html'},
        'body': html
    }
