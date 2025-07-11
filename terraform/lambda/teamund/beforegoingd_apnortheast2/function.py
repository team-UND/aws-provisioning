import json
import os
import urllib.request
import boto3

secrets_manager_client = None
cached_secrets = {}

def get_secret(secret_arn):
    global secrets_manager_client
    global cached_secrets

    if secret_arn in cached_secrets:
        return cached_secrets[secret_arn]

    if secrets_manager_client is None:
        region_name = os.environ.get("AWS_REGION")
        secrets_manager_client = boto3.client(
            service_name='secretsmanager',
            region_name=region_name
        )

    try:
        get_secret_value_response = secrets_manager_client.get_secret_value(
            SecretId=secret_arn
        )
        secret_string = get_secret_value_response['SecretString']
        
        parsed_secret = json.loads(secret_string)
        
        cached_secrets[secret_arn] = parsed_secret
        return parsed_secret
    except Exception as e:
        print(f"ERROR: Could not retrieve secret '{secret_arn}' from Secrets Manager: {e}")
        raise e

def lambda_handler(event, context):
    try:
        body = event.get('body')
        sentry_event = json.loads(body) if body else event
    except Exception as e:
        print(f"ERROR: Failed to parse event. Reason: {e}")
        print(f"Received raw event: {json.dumps(event)}")
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid event format from Sentry.')
        }

    try:
        secret_arn = os.environ['DISCORD_SECRET_ARN']
        app_secrets = get_secret(secret_arn)
        discord_webhook_url = app_secrets['DISCORD_WEBHOOK_URL']
    except KeyError as e:
        print(f"ERROR: Missing required environment variable or secret key: {e}")
        raise
    except Exception:
        print(f"CRITICAL ERROR: Halting execution due to secret retrieval failure.")
        raise

    event_data = sentry_event.get('data', {}).get('event', {})

    tags = {k: v for k, v in event_data.get('tags', [])}

    title = event_data.get('title') or event_data.get('metadata', {}).get('type', '') + ': ' + event_data.get('metadata', {}).get('value', '')
    if not title or title == ': ':
        title = event_data.get('message', 'No title')

    description = event_data.get('message', '')
    environment = tags.get('environment', event_data.get('environment', 'unknown'))
    level = tags.get('level', event_data.get('level', 'error')).lower()
    url = event_data.get('web_url')
    timestamp = event_data.get('datetime', '')

    req = event_data.get('request', {})
    method = req.get('method', '')
    req_url = req.get('url', tags.get('url', ''))
    user_agent = ''

    for header in req.get('headers', []):
        if header[0].lower() == 'user-agent':
            user_agent = header[1]

    color_map = {
        "fatal": 10038562,
        "error": 13458524,
        "warning": 16777113,
        "info": 10478271,
        "debug": 8421504
    }
    color = color_map.get(level, 10478271)

    fields = [
        {"name": "environment", "value": environment, "inline": True},
        {"name": "level", "value": level.capitalize(), "inline": True},
        {"name": "Request URL", "value": req_url},
        {"name": "method", "value": method, "inline": True},
        {"name": "User-Agent", "value": user_agent},
        {"name": "View in Sentry", "value": f"[Issue Details]({url})", "inline": False}
    ]

    discord_data = {
        "content": "Sentry Issue",
        "embeds": [
            {
                "title": title,
                "description": description,
                "color": color,
                "fields": fields,
                "footer": {"text": f"Event Time: {timestamp}"}
            }
        ]
    }

    headers = {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0'
    }
    req = urllib.request.Request(discord_webhook_url, data=json.dumps(discord_data).encode('utf-8'), headers=headers, method='POST')
    try:
        with urllib.request.urlopen(req) as response:
            response_body = response.read().decode('utf-8')
            print(f"SUCCESS: Discord notification sent. HTTP Status: {response.status}. Response: {response_body}")
    except urllib.error.HTTPError as e:
        error_response_body = e.read().decode('utf-8')
        print(f"ERROR: Failed to send Discord notification. HTTP Error: {e.code} - {e.reason}")
        print(f"Failing event payload: {json.dumps(sentry_event)}")
        print(f"Response body from Discord: {error_response_body}")
        raise
    except Exception as e:
        print(f"CRITICAL ERROR: Unexpected error while sending Discord notification: {e}")
        print(f"Failing event payload: {json.dumps(sentry_event)}")
        raise

    return {
        'statusCode': 200,
        'body': json.dumps('Discord notification sent successfully!')
    }
