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

if [ -z $INSTANCE_ID ]
then
	echo "INSTANCE_ID environment variable is not set.  Exiting."
	exit 1
fi

# Startup the ec2 instance
ec2_status=$(aws ec2 start-instances --instance-ids $INSTANCE_ID --output text --query StartingInstances[0].CurrentState.Name)

echo "The status of ec2 instance $INSTANCE_ID is $ec2_status"
if [ $ec2_status == "running" ]
then
	SLEEP=0
else
	echo "Starting host."
	SLEEP=20
fi

# Authorize the client's ip to access the ec2 host's security group
echo ;
IP=`curl -s http://whatismyip.akamai.com/`

echo "Updating the security group ingress rule to allow my current ip: $IP";
security_group_status=$(aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr $IP/32 --output text 2>&1)

if [[ $security_group_status == *"InvalidPermission.Duplicate"* ]]
then 
	echo "Ingress rule already exists.  Skipping."
else
	echo $security_group_status
fi

# Return the dns name of the ec2 instance
echo ;
echo "Waiting $SLEEP seconds to get the new dns name for the instance";
sleep $SLEEP
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

