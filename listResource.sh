#!/bin/bash

# Fetch all available regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

echo "Checking resources across all regions..."

# Initialize a JSON object
result="{"

# Loop through each region
for region in $regions; do
    echo "===================================="
    echo "Checking region: $region"
    echo "===================================="

    # Initialize region-specific JSON object
    region_result="{"

    # List EC2 Instances
    echo "EC2 Instances:"
    ec2_instances=$(aws ec2 describe-instances --region $region --query "Reservations[].Instances[].InstanceId" --output json)
    echo $ec2_instances
    region_result+="\"EC2Instances\": $ec2_instances,"

    # List EC2 Volumes (EBS)
    echo "EBS Volumes:"
    ebs_volumes=$(aws ec2 describe-volumes --region $region --query "Volumes[].VolumeId" --output json)
    echo $ebs_volumes
    region_result+="\"EBSVolumes\": $ebs_volumes,"

    # List Elastic IPs
    echo "Elastic IPs:"
    elastic_ips=$(aws ec2 describe-addresses --region $region --query "Addresses[].PublicIp" --output json)
    echo $elastic_ips
    region_result+="\"ElasticIPs\": $elastic_ips,"

    # List Snapshots
    echo "EBS Snapshots:"
    ebs_snapshots=$(aws ec2 describe-snapshots --region $region --owner-ids self --query "Snapshots[].SnapshotId" --output json)
    echo $ebs_snapshots
    region_result+="\"EBSSnapshots\": $ebs_snapshots,"

    # List Load Balancers
    echo "Elastic Load Balancers (v2):"
    elbs=$(aws elbv2 describe-load-balancers --region $region --query "LoadBalancers[].LoadBalancerName" --output json)
    echo $elbs
    region_result+="\"LoadBalancers\": $elbs,"

    # List NAT Gateways
    echo "NAT Gateways:"
    nat_gateways=$(aws ec2 describe-nat-gateways --region $region --query "NatGateways[].NatGatewayId" --output json)
    echo $nat_gateways
    region_result+="\"NATGateways\": $nat_gateways,"

    # List Elastic Network Interfaces
    echo "Elastic Network Interfaces:"
    network_interfaces=$(aws ec2 describe-network-interfaces --region $region --query "NetworkInterfaces[].NetworkInterfaceId" --output json)
    echo $network_interfaces
    region_result+="\"NetworkInterfaces\": $network_interfaces,"

    # List Auto Scaling Groups
    echo "Auto Scaling Groups:"
    asgs=$(aws autoscaling describe-auto-scaling-groups --region $region --query "AutoScalingGroups[].AutoScalingGroupName" --output json)
    echo $asgs
    region_result+="\"AutoScalingGroups\": $asgs,"

    # List Placement Groups
    echo "Placement Groups:"
    placement_groups=$(aws ec2 describe-placement-groups --region $region --query "PlacementGroups[].GroupName" --output json)
    echo $placement_groups
    region_result+="\"PlacementGroups\": $placement_groups,"

    # List Spot Fleets
    echo "Spot Fleets:"
    spot_fleets=$(aws ec2 describe-spot-fleet-requests --region $region --query "SpotFleetRequestConfigs[].SpotFleetRequestId" --output json)
    echo $spot_fleets
    region_result+="\"SpotFleets\": $spot_fleets,"

    # List VPCs
    echo "VPCs:"
    vpcs=$(aws ec2 describe-vpcs --region $region --query "Vpcs[].VpcId" --output json)
    echo $vpcs
    region_result+="\"VPCs\": $vpcs,"

    # List Subnets
    echo "Subnets:"
    subnets=$(aws ec2 describe-subnets --region $region --query "Subnets[].SubnetId" --output json)
    echo $subnets
    region_result+="\"Subnets\": $subnets,"

    # List Internet Gateways
    echo "Internet Gateways:"
    internet_gateways=$(aws ec2 describe-internet-gateways --region $region --query "InternetGateways[].InternetGatewayId" --output json)
    echo $internet_gateways
    region_result+="\"InternetGateways\": $internet_gateways,"

    # List SQS Queues
    echo "SQS Queues:"
    sqs_queues=$(aws sqs list-queues --region $region --query "QueueUrls[]" --output json)
    echo $sqs_queues
    region_result+="\"SQSQueues\": $sqs_queues,"

    # List Secrets Manager Secrets
    echo "Secrets Manager Secrets:"
    secrets=$(aws secretsmanager list-secrets --region $region --query "SecretList[].Name" --output json)
    echo $secrets
    region_result+="\"SecretsManager\": $secrets,"

    # List CodeCommit Repositories
    echo "CodeCommit Repositories:"
    codecommit_repos=$(aws codecommit list-repositories --region $region --query "repositories[].repositoryName" --output json)
    echo $codecommit_repos
    region_result+="\"CodeCommit\": $codecommit_repos,"

    # List CloudWatch Alarms
    echo "CloudWatch Alarms:"
    cloudwatch_alarms=$(aws cloudwatch describe-alarms --region $region --query "MetricAlarms[].AlarmName" --output json)
    echo $cloudwatch_alarms
    region_result+="\"CloudWatchAlarms\": $cloudwatch_alarms,"

    # List SageMaker Notebooks
    echo "SageMaker Notebooks:"
    sagemaker_notebooks=$(aws sagemaker list-notebook-instances --region $region --query "NotebookInstances[].NotebookInstanceName" --output json)
    echo $sagemaker_notebooks
    region_result+="\"SageMakerNotebooks\": $sagemaker_notebooks,"

    # CloudWatch Logs
    echo "CloudWatch Log Groups:"
    log_groups=$(aws logs describe-log-groups --region $region --query "logGroups[].logGroupName" --output json)
    echo $log_groups
    region_result+="\"CloudWatchLogs\": $log_groups,"

    # List S3 Buckets (global service, check once)
    if [ "$region" == "us-east-1" ]; then
        echo "S3 Buckets:"
        s3_buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output json)
        echo $s3_buckets
        region_result+="\"S3Buckets\": $s3_buckets,"
    fi

    # List ECR Repositories
    echo "ECR Repositories:"
    ecr_repos=$(aws ecr describe-repositories --region $region --query "repositories[].repositoryName" --output json)
    echo $ecr_repos
    region_result+="\"ECRRepositories\": $ecr_repos,"

    # List CodeBuild Projects
    echo "CodeBuild Projects:"
    codebuild_projects=$(aws codebuild list-projects --region $region --query "projects[]" --output json)
    echo $codebuild_projects
    region_result+="\"CodeBuildProjects\": $codebuild_projects,"

    # List Lambda Functions
    echo "Lambda Functions:"
    lambda_functions=$(aws lambda list-functions --region $region --query "Functions[].FunctionName" --output json)
    echo $lambda_functions
    region_result+="\"LambdaFunctions\": $lambda_functions,"

    # List Elastic File Systems
    echo "Elastic File Systems:"
    efs=$(aws efs describe-file-systems --region $region --query "FileSystems[].FileSystemId" --output json)
    echo $efs
    region_result+="\"EFS\": $efs,"

    # List DynamoDB Tables
    echo "DynamoDB Tables:"
    dynamodb_tables=$(aws dynamodb list-tables --region $region --query "TableNames[]" --output json)
    echo $dynamodb_tables
    region_result+="\"DynamoDBTables\": $dynamodb_tables,"

    # List CloudWatch Events
    echo "CloudWatch Events (Event Rules):"
    cloudwatch_events=$(aws events list-rules --region $region --query "Rules[].Name" --output json)
    echo $cloudwatch_events
    region_result+="\"CloudWatchEvents\": $cloudwatch_events,"

    # List Key Management Service Keys
    echo "KMS Keys:"
    kms_keys=$(aws kms list-keys --region $region --query "Keys[].KeyId" --output json)
    echo $kms_keys
    region_result+="\"KMSKeys\": $kms_keys,"

    # List SNS Topics
    echo "SNS Topics:"
    sns_topics=$(aws sns list-topics --region $region --query "Topics[].TopicArn" --output json)
    echo $sns_topics
    region_result+="\"SNSTopics\": $sns_topics,"

    # List AMI IDs
    echo "AMI IDs:"
    ami_ids=$(aws ec2 describe-images --region $region --owners self --query "Images[].ImageId" --output json)
    echo $ami_ids
    region_result+="\"AMIs\": $ami_ids,"

    # List RDS Instances
    echo "RDS Instances:"
    rds_instances=$(aws rds describe-db-instances --region $region --query "DBInstances[].DBInstanceIdentifier" --output json)
    echo $rds_instances
    region_result+="\"RDSInstances\": $rds_instances,"

    # List DocumentDB Clusters
    echo "DocumentDB Clusters:"
    docdb_clusters=$(aws docdb describe-db-clusters --region $region --query "DBClusters[].DBClusterIdentifier" --output json)
    echo $docdb_clusters
    region_result+="\"DocumentDBClusters\": $docdb_clusters,"

    # Remove trailing comma and close JSON object
    region_result=$(echo $region_result | sed 's/,$//')
    region_result+="}"

    # Append region result to main JSON object
    result+="\"$region\": $region_result,"
    
    echo ""
done

# Remove trailing comma and close JSON object
result=$(echo $result | sed 's/,$//')
result+="}"

# Output the final JSON object
echo $result | jq .

# Save the result to a JSON file
echo $result | jq . > aws_resources.json

echo "Resource check complete and saved to aws_resources.json."
