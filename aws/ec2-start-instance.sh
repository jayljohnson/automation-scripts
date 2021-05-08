#!/bin/bash

######
#
# Starts an ect instance that is stopped, returns the latest dns name, 
# and updates the VPC security group to allow traffic from the calling host.
# The purpsoes is to have an EC2 dev box that can be stopped to save money, 
# and quickly started on demand.
#
# Usage:
# set the EC2 instance ID as INSTANCE_ID
# Set the security group as SECURITY_GROUP_ID
# 	Example:
# 	INSTANCE_ID=i-0e4889b229035e771 SECURITY_GROUP_ID=sg-065c9be5359a994e8 ./ec2-start-instance.sh
#
#   VSCODE_SSH_CONFIG_PATH="/mnt/c/Users/Jay/.ssh/config"
#   VSCODE_SSH_PEM_FILE_PATH="C:\Users\Jay\OneDrive\Documents\dev-gl\default-remote-dev.pem"
#   SSH_PEM_FILE_PATH="~/aws/default-remote-dev.pem"
######

aws ec2 start-instances --instance-ids $INSTANCE_ID

# Authorize the client's ip to access the ec2 host's security group
IP=`curl -s http://whatismyip.akamai.com/`
echo "Updating the security group to my current ip: $IP";
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr $IP/32 --output text

# Return the dns name of the ec2 instance
echo "Waiting to get the new dns name for the instance";
sleep 20
public_dns=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query Reservations[0].Instances[0].NetworkInterfaces[].Association.PublicDnsName)
echo "The dns name is: $public_dns";

# Update the vscode config with the dns name of the ec2 instance
echo "Updating the vscode config with the new dns name";
cat > $VSCODE_SSH_CONFIG_PATH <<EOL
Host $public_dns
  HostName $public_dns
  User ec2-user
  IdentityFile $VSCODE_SSH_PEM_FILE_PATH
EOL

# Connect via ssh client to the ec2 host
echo "Connecting to the ec2 host";
ssh -i $SSH_PEM_FILE_PATH ec2-user@$public_dns
/