# automation-scripts

No warranty is provided, use at your own risk!

## Setup
Prerequisites: 
1. An EC2 host in running or stopped state
2. A .pem file granting access to the remote ec2 host

Local setup:
1. Copy the local.env.template `cp local.env.template local.env`
2. Populate the local.env with your EC2 instance and .pem details
3. Run `source local.env`

## Usage
### /aws/ec2-start/instance.sh
Prerequisites: 
1. README.md setup steps are complete
2. VSCode running on a windows machine
3. Windows with wsl2
4. An EC2 host in running or stopped state

What this script does:
1. Startup an EC2 instance id
2. Grant security group access to the local IP address
3. Update the VS Code remote ssh config file with the EC2 dns name
4. Establish a SSH connection to the EC2 host in the current terminal

