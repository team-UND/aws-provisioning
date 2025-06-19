import json
import os
import urllib.request
import urllib.parse

def lambda_handler(event, context):
    discord_webhook_url = os.environ['DISCORD_WEBHOOK_URL']
    aws_region = os.environ['AWS_REGION']

    try:
        codedeploy_event_str = event['Records'][0]['Sns']['Message']
        codedeploy_event = json.loads(codedeploy_event_str)
    except (KeyError, json.JSONDecodeError) as e:
        print(f"ERROR: Failed to parse event from SNS. Reason: {e}")
        print(f"Received raw event: {json.dumps(event)}")
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid event format from SNS/CodeDeploy.')
        }
    
    application_name = codedeploy_event.get('applicationName', 'N/A')
    deployment_group_name = codedeploy_event.get('deploymentGroupName', 'N/A')
    deployment_id = codedeploy_event.get('deploymentId', 'N/A')
    status = codedeploy_event.get('status', codedeploy_event.get('state', 'UNKNOWN')).upper()
    create_time = codedeploy_event.get('createTime', 'N/A') 

    # Construct the Discord message payload
    color = 0
    status_emoji = ""
    status_text = ""

    if status == "SUCCEEDED":
        color = 10478271
        status_emoji = "✅"
        status_text = "배포 성공!"
    elif status == "FAILED":
        color = 13458524
        status_emoji = "❌"
        status_text = "배포 실패!"
    elif status == "STOPPED":
        color = 16777113
        status_emoji = "⏹️"
        status_text = "배포 중단!"
    else:
        color = 8421504 # Gray (0x808080)
        status_emoji = "ℹ️"
        status_text = f"배포 상태: {status}"

    # Generate the AWS Console link for the deployment
    encoded_deployment_id = urllib.parse.quote_plus(deployment_id)
    deployment_link = f"https://{aws_region}.console.aws.amazon.com/codesuite/codedeploy/deployments/{encoded_deployment_id}/view?region={aws_region}"

    description = f"**Application:** {application_name}\n" \
                  f"**Deployment Group:** {deployment_group_name}\n" \
                  f"**Deployment ID:** {deployment_id}\n" \
                  f"**Status:** {status_emoji} {status_text}"

    discord_data = {
        "embeds": [
            {
                "title": "CodeDeploy Deployment Notification",
                "description": description,
                "color": color,
                "fields": [
                    {"name": "View in Console", "value": f"[Deployment Details]({deployment_link})", "inline": False}
                ],
                "footer": {
                    "text": f"Event Time: {create_time}"
                }
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
        if e.code == 403 and "code" in error_response_body and json.loads(error_response_body).get("code") == 10010:
            print("HINT: The Discord Webhook URL is likely invalid or expired. Please check your DISCORD_WEBHOOK_URL environment variable.")
        raise
    except Exception as e:
        print(f"CRITICAL ERROR: Unexpected error while sending Discord notification: {e}")
        raise

    return {
        'statusCode': 200,
        'body': json.dumps('Discord notification sent successfully!')
    }