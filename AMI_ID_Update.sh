#!/bin/bash

# Variables
INSTANCE_ID="i-013c4cb47635f943c"
REGION="ap-south-1"
AMI_NAME="MyServerAMI"
AMI_DESCRIPTION="Backup of my server"
LAUNCH_TEMPLATE_ID="lt-00489838eee06dd55"
SOURCE_VERSION="1"
ASG_NAME="ASG-CMOL"

# Create the AMI
AMI_ID=$(aws ec2 create-image \
    --instance-id "$INSTANCE_ID" \
    --name "$AMI_NAME" \
    --description "$AMI_DESCRIPTION" \
    --no-reboot \
    --region "$REGION" \
    --query 'ImageId' \
    --output text)

# Check if the AMI creation was successful
if [ $? -ne 0 ]; then
    echo "Failed to create AMI."
    exit 1
else
    echo "AMI created successfully. AMI ID: $AMI_ID"
fi

# Update the launch template with the new AMI
LT_VERSION=$(aws ec2 create-launch-template-version \
    --launch-template-id "$LAUNCH_TEMPLATE_ID" \
    --source-version "$SOURCE_VERSION" \
    --launch-template-data "{\"ImageId\":\"$AMI_ID\"}" \
    --query 'LaunchTemplateVersion.VersionNumber' \
    --output text \
    --region "$REGION")

# Check if the launch template update was successful
if [ $? -ne 0 ]; then
    echo "Failed to update the launch template."
    exit 1
else
    echo "Launch template updated successfully. New Version Number: $LT_VERSION"
fi

# Update the Auto Scaling Group with the new launch template version
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "$ASG_NAME" \
    --launch-template "LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version=$LT_VERSION" \
    --region "$REGION"

# Check if the ASG update was successful
if [ $? -ne 0 ]; then
    echo "Failed to update the Auto Scaling Group."
    exit 1
else
    echo "Auto Scaling Group updated successfully with Launch Template Version: $LT_VERSION"
fi

#start-instance-refresh
#aws autoscaling start-instance-refresh --auto-scaling-group-name ASG-CMOL --region ap-south-1
