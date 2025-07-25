
import os
import json
import logging
import hmac
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# --- Global Scope Initialization ---
# Initialize clients and load configuration outside the handler for performance
# and fail-fast behavior on misconfiguration.
try:
    SECRET_ARN = os.environ['ORIGIN_VERIFY_SECRET_ARN']
    # Normalize header name to lowercase once.
    HEADER_NAME = os.environ.get('ORIGIN_VERIFY_HEADER_NAME', 'x-origin-verify').lower()
    SECRETS_MANAGER_CLIENT = boto3.client('secretsmanager')
except KeyError as e:
    # If critical environment variables are missing, log a critical error
    # and raise an exception. This will cause the Lambda initialization to fail,
    # which is a clear and immediate signal of a configuration problem.
    logger.critical(f"CRITICAL: Missing required environment variable: {e}. Lambda cannot start.")
    raise

cached_secret = None

def lambda_handler(event, context):
    global cached_secret
    is_authorized = False

    try:
        # The secret is fetched only once per container lifetime.
        if cached_secret is None:
            logger.info("Secret not cached. Fetching from Secrets Manager.")
            secret_value_response = SECRETS_MANAGER_CLIENT.get_secret_value(SecretId=SECRET_ARN)
            cached_secret = secret_value_response['SecretString']

        incoming_secret = event.get('headers', {}).get(HEADER_NAME)

        # Use hmac.compare_digest for secure, constant-time comparison to prevent timing attacks.
        if incoming_secret and cached_secret and hmac.compare_digest(incoming_secret, cached_secret):
            logger.info("Successfully verified secret header. Allowing request.")
            is_authorized = True
        else:
            # Log a warning only if a secret was provided but was incorrect.
            if incoming_secret:
                logger.warning("Verification failed: Incoming secret does not match stored secret.")
    except ClientError as e:
        # If fetching the secret fails, log the error and deny access.
        # Resetting the cache allows for a retry on the next invocation.
        logger.error(f"Error communicating with AWS Secrets Manager: {e}")
        cached_secret = None
    except Exception as e:
        # Catch any other unexpected errors.
        logger.error(f"Error during authorization: {e}")

    return {"isAuthorized": is_authorized}
