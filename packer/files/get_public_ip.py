import boto3

ec2_client = boto3.client('ec2')
response = ec2_client.describe_instances()

# Get instance id
def get_ec2_public_ip(instance_id):
    """Retrieves the public IP address of an EC2 instance."""

    ec2_client = boto3.client('ec2')

    try:
        response = ec2_client.describe_instances(InstanceIds=[instance_id])
        reservations = response['Reservations']

        for reservation in reservations:
            for instance in reservation['Instances']:
                public_ip = instance.get('PublicIpAddress')
                if public_ip:
                    return public_ip

    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    instance_id = "INSTANCE_ID"  # Replace EC2 instance ID
    public_ip = get_ec2_public_ip(instance_id)

    if public_ip:
     with open('public_ip.txt', 'w') as f:
        print(f"Public IP: {public_ip}", file=f)
    else:
        print("Public IP not found.")

# Upload the file to S3
s3 = boto3.client('s3')
s3.upload_file('/data/public_ip.txt', 'proving-web-server-1', 'public_ip.txt')
