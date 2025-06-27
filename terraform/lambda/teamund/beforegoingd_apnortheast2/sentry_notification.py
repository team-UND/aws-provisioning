import json
import os
import urllib.request

def lambda_handler(event, context):
    discord_webhook_url = os.environ['DISCORD_WEBHOOK_URL']

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
        {"name": "View in Sentry", "value": f"[Issue Details]({url})", "inline": False},
        {"name": "environment", "value": environment, "inline": True},
        {"name": "level", "value": level.capitalize(), "inline": True},
    ]
    if req_url:
        fields.append({"name": "Request URL", "value": req_url})
    if method:
        fields.append({"name": "method", "value": method, "inline": True})
    if user_agent:
        fields.append({"name": "User-Agent", "value": user_agent})

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
        print(f"Response body from Discord: {error_response_body}")
        raise
    except Exception as e:
        print(f"CRITICAL ERROR: Unexpected error while sending Discord notification: {e}")
        raise

    return {
        'statusCode': 200,
        'body': json.dumps('Discord notification sent successfully!')
    }
