# AWS WebSocket API Echo Server

This repository contains the Terraform configuration and Lambda function code (Python) for setting up a simple WebSocket API using AWS API Gateway. The Lambda function is designed to echo back messages sent by clients, demonstrating basic WebSocket functionality.

## Overview

The project sets up:
- AWS API Gateway WebSocket API
- Lambda functions for connection management (connect, disconnect) and message echoing (sendmessage)
- IAM roles and policies for Lambda and API Gateway

## Prerequisites

- AWS Account
- Terraform installed
- AWS CLI configured with appropriate permissions
- Basic knowledge of AWS services (Lambda, API Gateway, IAM)
- Pyton 3.10

## Setup and Deployment

1. **Clone the Repository**
```sh
git clone https://github.com/jb-is-batman/terraform-websocket-chat
cd terraform-websocket-chat
```

2. Initialize Terraform
```sh
terraform init
```

3. Apply Terraform Configuration
```sh
terraform apply
```

## Using the WebSocket API
- Connect to the WebSocket URL provided by API Gateway after deployment.
  - There are free services like [WebSocket Tester](https://www.piesocket.com/websocket-tester) to test your connection 
- Send a message in JSON format, e.g., ```{"action": "sendmessage", "message": "Hello World"}```.
- The sendmessage Lambda function will echo the message back to you.

## Future Enhancements
- Implement authentication and authorization (e.g., using Amazon Cognito or Lambda Authorizers).
- Add more complex message handling and business logic.