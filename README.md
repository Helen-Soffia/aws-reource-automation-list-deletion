# aws-reource-automation-list-deletion

This script retrieves and lists various AWS resources across all available regions using the AWS CLI. The output is formatted as a JSON object and saved to a file named `aws_resources.json`.

## Prerequisites

1. **AWS CLI**: Ensure that the AWS CLI is installed and configured on your system. You can install it from the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

2. **jq**: The script uses `jq` for formatting the JSON output. Install it from [jq's official site](https://stedolan.github.io/jq/download/).

## Script Overview

The script performs the following actions:
- Fetches all available AWS regions.
- Queries various AWS services to list resources including EC2 Instances, EBS Volumes, Elastic IPs, Snapshots, Load Balancers, NAT Gateways, Network Interfaces, Auto Scaling Groups, Placement Groups, Spot Fleets, VPCs, Subnets, Internet Gateways, SQS Queues, Secrets Manager Secrets, CodeCommit Repositories, CloudWatch Alarms, SageMaker Notebooks, CloudWatch Log Groups, S3 Buckets, ECR Repositories, CodeBuild Projects, Lambda Functions, Elastic File Systems, DynamoDB Tables, CloudWatch Events, KMS Keys, SNS Topics, AMIs, RDS Instances, and DocumentDB Clusters.
- Formats the results into a JSON object.
- Saves the JSON object to `aws_resources.json`.

## Usage

1. **Clone or Download the Script**: Save the script to a file, for example, `listReources.sh`.

2. **Make the Script Executable**:
   ```bash
   chmod +x listResource.sh
