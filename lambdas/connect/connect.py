import json

def lambda_handler(event, context):
  print("Event: ", event)
  print("Context: ", context)
  return {'statusCode': 200,}