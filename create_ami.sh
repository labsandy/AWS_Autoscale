#!/bin/bash 
#aws ec2 create-image --instance-id i-013c4cb47635f943c --name "MyServerAMI" --description "Backup of my server" --no-reboot --region ap-south-1
AMI_ID=$(aws ec2 create-image --instance-id i-013c4cb47635f943c --name "MyServerAMI" --description "Backup of my server" --no-reboot --region ap-south-1 --query 'ImageId' --output text) && echo "AMI created successfully. AMI ID: $AMI_ID" || echo "Failed to create AMI."
