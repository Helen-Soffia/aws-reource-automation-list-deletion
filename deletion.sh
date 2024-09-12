#!/bin/bash

# File containing the JSON data
json_file="aws_resources.json"

# Read the JSON file
json_data=$(cat $json_file)

# Function to delete EC2 instances
delete_ec2_instances() {
    local region=$1
    local instances=$2

    if [ -n "$instances" ]; then
        for instance in $instances; do
            echo "Deleting EC2 instance $instance in region $region"
            aws ec2 terminate-instances --region $region --instance-ids $instance
        done
    fi
}

# Function to delete EBS volumes
delete_ebs_volumes() {
    local region=$1
    local volumes=$2

    if [ -n "$volumes" ]; then
        for volume in $volumes; do
            echo "Deleting EBS volume $volume in region $region"
            aws ec2 delete-volume --region $region --volume-id $volume
        done
    fi
}

# Function to delete Elastic IPs
delete_elastic_ips() {
    local region=$1
    local ips=$2

    if [ -n "$ips" ]; then
        for ip in $ips; do
            echo "Releasing Elastic IP $ip in region $region"
            allocation_id=$(aws ec2 describe-addresses --region $region --query "Addresses[?PublicIp=='$ip'].AllocationId" --output text)
            if [ "$allocation_id" != "None" ]; then
                aws ec2 release-address --region $region --allocation-id $allocation_id
            fi
        done
    fi
}

# Function to delete snapshots
delete_snapshots() {
    local region=$1
    local snapshots=$2

    if [ -n "$snapshots" ]; then
        for snapshot in $snapshots; do
            echo "Deleting snapshot $snapshot in region $region"
            aws ec2 delete-snapshot --region $region --snapshot-id $snapshot
        done
    fi
}

# Function to delete load balancers
delete_load_balancers() {
    local region=$1
    local load_balancers=$2

    if [ -n "$load_balancers" ]; then
        for lb in $load_balancers; do
            echo "Deleting load balancer $lb in region $region"
            aws elbv2 delete-load-balancer --region $region --load-balancer-arn $lb
        done
    fi
}

# Function to delete NAT Gateways
delete_nat_gateways() {
    local region=$1
    local nat_gateways=$2

    if [ -n "$nat_gateways" ]; then
        for nat_gateway in $nat_gateways; do
            echo "Deleting NAT Gateway $nat_gateway in region $region"
            aws ec2 delete-nat-gateway --region $region --nat-gateway-id $nat_gateway
        done
    fi
}

# Function to delete network interfaces
delete_network_interfaces() {
    local region=$1
    local network_interfaces=$2

    if [ -n "$network_interfaces" ]; then
        for ni in $network_interfaces; do
            echo "Deleting network interface $ni in region $region"
            aws ec2 delete-network-interface --region $region --network-interface-id $ni
        done
    fi
}

# Function to delete auto scaling groups
delete_auto_scaling_groups() {
    local region=$1
    local auto_scaling_groups=$2

    if [ -n "$auto_scaling_groups" ]; then
        for asg in $auto_scaling_groups; do
            echo "Deleting auto scaling group $asg in region $region"
            aws autoscaling delete-auto-scaling-group --region $region --auto-scaling-group-name $asg --force-delete
        done
    fi
}

# Function to delete placement groups
delete_placement_groups() {
    local region=$1
    local placement_groups=$2

    if [ -n "$placement_groups" ]; then
        for pg in $placement_groups; do
            echo "Deleting placement group $pg in region $region"
            aws ec2 delete-placement-group --region $region --group-name $pg
        done
    fi
}

# Function to delete spot fleets
delete_spot_fleets() {
    local region=$1
    local spot_fleets=$2

    if [ -n "$spot_fleets" ]; then
        for spot_fleet in $spot_fleets; do
            echo "Deleting spot fleet $spot_fleet in region $region"
            aws ec2 cancel-spot-fleet-requests --region $region --spot-fleet-request-ids $spot_fleet
        done
    fi
}

# Function to delete VPCs
delete_vpcs() {
    local region=$1
    local vpcs=$2

    if [ -n "$vpcs" ]; then
        for vpc in $vpcs; do
            # Skip default VPC
            default_vpc=$(aws ec2 describe-vpcs --region $region --vpc-ids $vpc --query "Vpcs[0].IsDefault" --output text)
            if [ "$default_vpc" == "True" ]; then
                echo "Skipping default VPC $vpc in region $region"
            else
                echo "Deleting VPC $vpc in region $region"
                aws ec2 delete-vpc --region $region --vpc-id $vpc
            fi
        done
    fi
}

# Function to delete subnets
delete_subnets() {
    local region=$1
    local subnets=$2

    if [ -n "$subnets" ]; then
        for subnet in $subnets; do
            # Skip default subnets
            default_subnet=$(aws ec2 describe-subnets --region $region --subnet-ids $subnet --query "Subnets[0].DefaultForAz" --output text)
            if [ "$default_subnet" == "True" ]; then
                echo "Skipping default subnet $subnet in region $region"
            else
                echo "Deleting subnet $subnet in region $region"
                aws ec2 delete-subnet --region $region --subnet-id $subnet
            fi
        done
    fi
}

# Function to delete internet gateways
delete_internet_gateways() {
    local region=$1
    local internet_gateways=$2

    if [ -n "$internet_gateways" ]; then
        for igw in $internet_gateways; do
            # Check if the IGW is attached before deleting
            attachments=$(aws ec2 describe-internet-gateways --region $region --internet-gateway-ids $igw --query "InternetGateways[0].Attachments" --output text)
            if [ -n "$attachments" ]; then
                echo "Detaching and deleting internet gateway $igw in region $region"
                vpc_id=$(echo $attachments | awk '{print $1}')
                aws ec2 detach-internet-gateway --region $region --internet-gateway-id $igw --vpc-id $vpc_id
                aws ec2 delete-internet-gateway --region $region --internet-gateway-id $igw
            else
                echo "Deleting internet gateway $igw in region $region"
                aws ec2 delete-internet-gateway --region $region --internet-gateway-id $igw
            fi
        done
    fi
}

# Function to delete SQS queues
delete_sqs_queues() {
    local region=$1
    local queues=$2

    if [ -n "$queues" ]; then
        for queue in $queues; do
            echo "Deleting SQS queue $queue in region $region"
            aws sqs delete-queue --region $region --queue-url $queue
        done
    fi
}

# Function to delete secrets
delete_secrets() {
    local region=$1
    local secrets=$2

    if [ -n "$secrets" ]; then
        for secret in $secrets; do
            echo "Deleting secret $secret in region $region"
            aws secretsmanager delete-secret --region $region --secret-id $secret --force-delete-without-recovery
        done
    fi
}

# Function to delete CodeCommit repositories
delete_codecommit_repos() {
    local region=$1
    local repos=$2

    if [ -n "$repos" ]; then
        for repo in $repos; do
            echo "Deleting CodeCommit repository $repo in region $region"
            aws codecommit delete-repository --region $region --repository-name $repo
        done
    fi
}

# Function to delete CloudWatch alarms
delete_cloudwatch_alarms() {
    local region=$1
    local alarms=$2

    if [ -n "$alarms" ]; then
        for alarm in $alarms; do
            echo "Deleting CloudWatch alarm $alarm in region $region"
            aws cloudwatch delete-alarms --region $region --alarm-names $alarm
        done
    fi
}

# Function to delete SageMaker notebooks
delete_sagemaker_notebooks() {
    local region=$1
    local notebooks=$2

    if [ -n "$notebooks" ]; then
        for notebook in $notebooks; do
            echo "Deleting SageMaker notebook instance $notebook in region $region"
            aws sagemaker delete-notebook-instance --region $region --notebook-instance-name $notebook
        done
    fi
}

# Function to delete CloudWatch log groups
delete_cloudwatch_logs() {
    local region=$1
    local log_groups=$2

    if [ -n "$log_groups" ]; then
        for log_group in $log_groups; do
            echo "Deleting CloudWatch log group $log_group in region $region"
            aws logs delete-log-group --region $region --log-group-name $log_group
        done
    fi
}

# Function to delete ECR repositories
delete_ecr_repos() {
    local region=$1
    local repos=$2

    if [ -n "$repos" ]; then
        for repo in $repos; do
            echo "Deleting ECR repository $repo in region $region"
            aws ecr delete-repository --region $region --repository-name $repo --force
        done
    fi
}

# Function to delete CodeBuild projects
delete_codebuild_projects() {
    local region=$1
    local projects=$2

    if [ -n "$projects" ]; then
        for project in $projects; do
            echo "Deleting CodeBuild project $project in region $region"
            aws codebuild delete-project --region $region --name $project
        done
    fi
}

# Function to delete Lambda functions
delete_lambda_functions() {
    local region=$1
    local functions=$2

    if [ -n "$functions" ]; then
        for function in $functions; do
            echo "Deleting Lambda function $function in region $region"
            aws lambda delete-function --region $region --function-name $function
        done
    fi
}

# Function to delete Elastic File Systems
delete_efs() {
    local region=$1
    local file_systems=$2

    if [ -n "$file_systems" ]; then
        for fs in $file_systems; do
            echo "Deleting EFS $fs in region $region"
            aws efs delete-file-system --region $region --file-system-id $fs
        done
    fi
}

# Function to delete DynamoDB tables
delete_dynamodb_tables() {
    local region=$1
    local tables=$2

    if [ -n "$tables" ]; then
        for table in $tables; do
            echo "Deleting DynamoDB table $table in region $region"
            aws dynamodb delete-table --region $region --table-name $table
        done
    fi
}

# Function to delete CloudWatch Events rules
delete_cloudwatch_events() {
    local region=$1
    local rules=$2

    if [ -n "$rules" ]; then
        for rule in $rules; do
            echo "Deleting CloudWatch event rule $rule in region $region"
            aws events delete-rule --region $region --name $rule
        done
    fi
}

# Function to delete KMS keys
delete_kms_keys() {
    local region=$1
    local keys=$2

    if [ -n "$keys" ]; then
        for key in $keys; do
            echo "Deleting KMS key $key in region $region"
            aws kms schedule-key-deletion --region $region --key-id $key --pending-window-in-days 7
        done
    fi
}

# Function to delete SNS topics
delete_sns_topics() {
    local region=$1
    local topics=$2

    if [ -n "$topics" ]; then
        for topic in $topics; do
            echo "Deleting SNS topic $topic in region $region"
            aws sns delete-topic --region $region --topic-arn $topic
        done
    fi
}

# Function to delete AMIs
delete_amis() {
    local region=$1
    local amis=$2

    if [ -n "$amis" ]; then
        for ami in $amis; do
            echo "Deregistering AMI $ami in region $region"
            aws ec2 deregister-image --region $region --image-id $ami
        done
    fi
}

# Parse JSON and perform deletions
for region in $(echo $json_data | jq -r 'keys[]'); do
    echo "Processing region: $region"

    ec2_instances=$(echo $json_data | jq -r --arg region "$region" '.[$region]["EC2Instances"] // [] | .[]?')
    delete_ec2_instances $region "$ec2_instances"

    ebs_volumes=$(echo $json_data | jq -r --arg region "$region" '.[$region]["EBSVolumes"] // [] | .[]?')
    delete_ebs_volumes $region "$ebs_volumes"

    elastic_ips=$(echo $json_data | jq -r --arg region "$region" '.[$region]["ElasticIPs"] // [] | .[]?')
    delete_elastic_ips $region "$elastic_ips"

    snapshots=$(echo $json_data | jq -r --arg region "$region" '.[$region]["EBSSnapshots"] // [] | .[]?')
    delete_snapshots $region "$snapshots"

    load_balancers=$(echo $json_data | jq -r --arg region "$region" '.[$region]["LoadBalancers"] // [] | .[]?')
    delete_load_balancers $region "$load_balancers"

    nat_gateways=$(echo $json_data | jq -r --arg region "$region" '.[$region]["NATGateways"] // [] | .[]?')
    delete_nat_gateways $region "$nat_gateways"

    network_interfaces=$(echo $json_data | jq -r --arg region "$region" '.[$region]["NetworkInterfaces"] // [] | .[]?')
    delete_network_interfaces $region "$network_interfaces"

    auto_scaling_groups=$(echo $json_data | jq -r --arg region "$region" '.[$region]["AutoScalingGroups"] // [] | .[]?')
    delete_auto_scaling_groups $region "$auto_scaling_groups"

    placement_groups=$(echo $json_data | jq -r --arg region "$region" '.[$region]["PlacementGroups"] // [] | .[]?')
    delete_placement_groups $region "$placement_groups"

    spot_fleets=$(echo $json_data | jq -r --arg region "$region" '.[$region]["SpotFleets"] // [] | .[]?')
    delete_spot_fleets $region "$spot_fleets"

    vpcs=$(echo $json_data | jq -r --arg region "$region" '.[$region]["VPCs"] // [] | .[]?')
    delete_vpcs $region "$vpcs"

    subnets=$(echo $json_data | jq -r --arg region "$region" '.[$region]["Subnets"] // [] | .[]?')
    delete_subnets $region "$subnets"

    internet_gateways=$(echo $json_data | jq -r --arg region "$region" '.[$region]["InternetGateways"] // [] | .[]?')
    delete_internet_gateways $region "$internet_gateways"

    sqs_queues=$(echo $json_data | jq -r --arg region "$region" '.[$region]["SQSQueues"] // [] | .[]?')
    delete_sqs_queues $region "$sqs_queues"

    secrets=$(echo $json_data | jq -r --arg region "$region" '.[$region]["SecretsManager"] // [] | .[]?')
    delete_secrets $region "$secrets"

    codecommit_repos=$(echo $json_data | jq -r --arg region "$region" '.[$region]["CodeCommit"] // [] | .[]?')
    delete_codecommit_repos $region "$codecommit_repos"

    cloudwatch_alarms=$(echo $json_data | jq -r --arg region "$region" '.[$region]["CloudWatchAlarms"] // [] | .[]?')
    delete_cloudwatch_alarms $region "$cloudwatch_alarms"

    sagemaker_notebooks=$(echo $json_data | jq -r --arg region "$region" '.[$region]["SageMakerNotebooks"] // [] | .[]?')
    delete_sagemaker_notebooks $region "$sagemaker_notebooks"

    cloudwatch_logs=$(echo $json_data | jq -r --arg region "$region" '.[$region]["CloudWatchLogs"] // [] | .[]?')
    delete_cloudwatch_logs $region "$cloudwatch_logs"

    ecr_repos=$(echo $json_data | jq -r --arg region "$region" '.[$region]["ECRRepositories"] // [] | .[]?')
    delete_ecr_repos $region "$ecr_repos"

    codebuild_projects=$(echo $json_data | jq -r --arg region "$region" '.[$region]["CodeBuildProjects"] // [] | .[]?')
    delete_codebuild_projects $region "$codebuild_projects"

    lambda_functions=$(echo $json_data | jq -r --arg region "$region" '.[$region]["LambdaFunctions"] // [] | .[]?')
    delete_lambda_functions $region "$lambda_functions"

    efs=$(echo $json_data | jq -r --arg region "$region" '.[$region]["EFS"] // [] | .[]?')
    delete_efs $region "$efs"

    dynamodb_tables=$(echo $json_data | jq -r --arg region "$region" '.[$region]["DynamoDBTables"] // [] | .[]?')
    delete_dynamodb_tables $region "$dynamodb_tables"

    cloudwatch_events=$(echo $json_data | jq -r --arg region "$region" '.[$region]["CloudWatchEvents"] // [] | .[]?')
    delete_cloudwatch_events $region "$cloudwatch_events"

    kms_keys=$(echo $json_data | jq -r --arg region "$region" '.[$region]["KMSKeys"] // [] | .[]?')
    delete_kms_keys $region "$kms_keys"

    sns_topics=$(echo $json_data | jq -r --arg region "$region" '.[$region]["SNSTopics"] // [] | .[]?')
    delete_sns_topics $region "$sns_topics"

    amis=$(echo $json_data | jq -r --arg region "$region" '.[$region]["AMIs"] // [] | .[]?')
    delete_amis $region "$amis"

    echo ""
done

echo "Resource deletion complete."
