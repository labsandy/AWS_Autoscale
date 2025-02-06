#!/bin/bash
set -vx

branch_name=$1

# Get the IP addresses (each IP will be on a new line)
IP_Addresses=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=CM-ASG" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].PrivateIpAddress" --output text --region ap-south-1)

# Loop through each IP address
for i in $IP_Addresses; do
  echo "Connecting to $i .." 
  ssh -o "StrictHostKeyChecking=no" -i "/home/jenkins/pem/cmprod-mumbai.pem" ubuntu@"$i" << EOF
    echo "Connected to $i"
    # Add any commands to execute on the remote server here
     cd /home/ubuntu/cmol-api.creditmantri.com/current &&
     sudo git fetch origin $branch_name &&
     sudo git checkout $branch_name && 
     sudo git pull origin $branch_name && 
     sudo service supervisor restart && 
     sudo service supervisor status
    exit
EOF
  echo "Connection to $i completed."
done
