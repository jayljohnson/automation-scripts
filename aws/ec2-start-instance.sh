#1/bin/bash

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
######

aws ec2 start-instances --instance-ids $INSTANCE_ID

IP=`curl -s http://whatismyip.akamai.com/`
echo "Updating the security group to my current ip: $IP"
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr $IP/32 --output text

echo "Waiting to get the new dns name for the instance"
sleep 20
public_dns=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query Reservations[0].Instances[0].NetworkInterfaces[].Association.PublicDnsName)
echo "The dns name is: $public_dns"
