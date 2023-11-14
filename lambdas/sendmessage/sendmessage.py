import json
import urllib
import boto3

def lambda_handler(event, context):
  domain_name   = event["requestContext"]["domainName"]
  stage         = event["requestContext"]["stage"]
  endpoint_url  = f"https://{domain_name}/{stage}"
  apig_management_client = boto3.client("apigatewaymanagementapi", endpoint_url=endpoint_url)
  
  connection_id = event["requestContext"]["connectionId"]
  body_str      = event.get("body", "{}")  
  body          = json.loads(body_str)
  message       = body.get("message", "")
  
  response = apig_management_client.post_to_connection(
    Data=json.dumps({"message": message}).encode("utf-8"),
    ConnectionId=connection_id
  )

  return {'statusCode': 200,}