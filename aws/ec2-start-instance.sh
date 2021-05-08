#!/bin/bash

######
#
# Starts an ect instance that is stopped, returns the latest dns name, 
# and updates the VPC security group to allow traffic from the calling host.
# The purpsoes is to have an EC2 dev box that can be stopped to save money, 
# and quickly started on demand.
#
# Usage:
# Copy local.env.template to local.env and set the environment variables
# Then, run `source local.env` and finally run this script
#
######

# Startup the ec2 instance
aws ec2 start-instances --instance-ids $INSTANCE_ID

# Authorize the client's ip to access the ec2 host's security group
echo ;
IP=`curl -s http://whatismyip.akamai.com/`
echo "Updating the security group to my current ip: $IP";
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr $IP/32 --output text

# Return the dns name of the ec2 instance
echo ;
echo "Waiting to get the new dns name for the instance";
sleep 20
public_dns=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query Reservations[0].Instances[0].NetworkInterfaces[].Association.PublicDnsName)
echo "The dns name is: $public_dns";

# Update the vscode config with the dns name of the ec2 instance
echo ;
echo "Updating the vscode config with the new dns name";
cat > $VSCODE_SSH_CONFIG_PATH <<EOL
Host $public_dns
  HostName $public_dns
  User ec2-user
  IdentityFile $VSCODE_SSH_PEM_FILE_PATH
EOL

# Connect via ssh client to the ec2 host
echo ;
echo "Connecting to the ec2 host";
echo "ssh -i $SSH_PEM_FILE_PATH ec2-user@$public_dns";
ssh -i $SSH_PEM_FILE_PATH ec2-user@$public_dns
/
