
import os
import json
import logging
import hmac
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

secrets_manager_client = None
cached_secret = None

def get_secrets_manager_client():
    global secrets_manager_client
    if secrets_manager_client is None:
        secrets_manager_client = boto3.client('secretsmanager')
    return secrets_manager_client

def generate_policy(principal_id, effect, resource):
    return {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource
            }]
        }
    }

def lambda_handler(event, context):
    global cached_secret
    
    try:
        secret_arn = os.environ['ORIGIN_VERIFY_SECRET_ARN']
        header_name = os.environ.get('VERIFY_HEADER_NAME', 'x-origin-verify')
    except KeyError as e:
        logger.error(f"Error: Missing required environment variable: {e}")
        return generate_policy('user', 'Deny', event['routeArn'])

    try:
        if cached_secret is None:
            logger.info("Secret not cached. Fetching from Secrets Manager.")
            client = get_secrets_manager_client()
            secret_value_response = client.get_secret_value(SecretId=secret_arn)
            cached_secret = secret_value_response['SecretString']

        incoming_secret = event.get('headers', {}).get(header_name.lower())

        if incoming_secret and cached_secret and hmac.compare_digest(incoming_secret, cached_secret):
            logger.info("Successfully verified secret header. Allowing request.")
            return generate_policy(context.aws_request_id, 'Allow', event['routeArn'])
        else:
            logger.warning("Verification failed: Incoming secret does not match stored secret.")
            return generate_policy('user', 'Deny', event['routeArn'])

    except ClientError as e:
        logger.error(f"Error communicating with AWS Secrets Manager: {e}")
        cached_secret = None
    except Exception as e:
        logger.error(f"Error during authorization: {e}")

    return generate_policy('user', 'Deny', event['routeArn'])
