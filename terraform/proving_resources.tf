# Configure the AWS Provider
provider "aws" {
  region  = "us-east-2"
}

#Create Security Group for ASG
resource "aws_security_group" "proving_asg_sg" {
  name        = "Proving_ASG_Inbound"
  description = "Inbound Traffic"
  vpc_id      = data.aws_vpc.GetVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "proving asg security group"
  }
}

#Create Security Group for ASG 2
resource "aws_security_group" "proving_asg_sg_2" {
  name        = "Proving_ASG_Inbound_2"
  description = "Inbound Traffic"
  vpc_id      = data.aws_vpc.GetVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "proving asg security group 2"
  }
}

#Create s3 proving bucket 1
resource "aws_s3_bucket" "proving_web_server_1" {
  bucket = "proving-web-server-1"

  tags   = {
    Name = "proving-web-server-1"
  }
}

#Create ec2 proving1 role
resource "aws_iam_role" "proving1_iam_ec2_s3_role" {
  name = "proving1_iam_ec2_s3_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

#Create ec2 proving2 role
resource "aws_iam_role" "proving2_iam_ec2_s3_role" {
  name = "proving2_iam_ec2_s3_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

data "aws_iam_policy_document" "proving1" {
  statement {
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }

  statement {
    sid = "proving1"

    actions   = ["s3:ListBucket",
                 "s3:PutObject",
                ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "proving1_source" {
  source_policy_documents = [data.aws_iam_policy_document.proving1.json]

  statement {
    sid = "proving1"

    actions = ["s3:ListBucket",
                 "s3:PutObject",]

    resources = [
      "arn:aws:s3:::proving-web-server-1",
      "arn:aws:s3:::proving-web-server-1/*",
    ]
  }
}

#Create proving1 role policy
resource "aws_iam_role_policy" "proving1_s3_write_access" {
  name        = "proving1_s3_write_access"
  role         = aws_iam_role.proving1_iam_ec2_s3_role.id
  policy      = data.aws_iam_policy_document.proving1_source.json
}

#resource "aws_iam_role_policy_attachment" "proving1_attachment" {
 # role       = aws_iam_role.proving1_iam_ec2_s3_role.name
  #policy_arn = aws_iam_policy.proving1_s3_write_access.arn
#}

#Create proving2 role policy
resource "aws_iam_role_policy" "proving2_s3_read_access" {
  name = "proving2_s3_read_access"
  role = aws_iam_role.proving2_iam_ec2_s3_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::proving-web-server-1","arn:aws:s3:::proving-web-server-1/*" ]
      }
    ]
  })
}

#Create proving profile 1
resource "aws_iam_instance_profile" "proving1_iam_ec2_s3_profile" {
  name = "proving1_iam_ec2_s3_profile"
  role = aws_iam_role.proving1_iam_ec2_s3_role.name
}

#Create proving profile 2
resource "aws_iam_instance_profile" "proving2_iam_ec2_s3_profile" {
  name = "proving2_iam_ec2_s3_profile"
  role = aws_iam_role.proving2_iam_ec2_s3_role.name
}

#Create Target Group for ASG
resource "aws_lb_target_group" "proving_asg_tg" {
  name        = "Proving-ASG-Target-Group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.GetVPC.id
  target_type = "instance"
}

#Create Target Group for ASG 2
resource "aws_lb_target_group" "proving_asg_tg_2" {
  name        = "Proving-ASG-Target-Group-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.GetVPC.id
  target_type = "instance"
}


#Create Launch Template for ASG
resource "aws_launch_template" "proving_asg_lt" {
  name_prefix     = "proving-web"
  image_id        = var.image_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = ["${aws_security_group.proving_asg_sg.id}"]
  iam_instance_profile {
    name = "${aws_iam_instance_profile.proving1_iam_ec2_s3_profile.name}"
  }
  user_data = filebase64("proving1_config.tpl") 
}

#Create Launch Template for ASG 2
resource "aws_launch_template" "proving_asg_lt_2" {
  name_prefix     = "proving-web2"
  image_id        = var.image_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = ["${aws_security_group.proving_asg_sg_2.id}"]
  iam_instance_profile {
    name = "${aws_iam_instance_profile.proving2_iam_ec2_s3_profile.name}"
  }
  user_data = filebase64("proving2_config.tpl") 
}

#Create Auto Scaling Group for ASG
resource "aws_autoscaling_group" "proving_asg" {
  min_size             = var.proving_asg_min_size
  max_size             = var.proving_asg_max_size
  desired_capacity     = var.proving_desired_capacity
  target_group_arns    = ["${aws_lb_target_group.proving_asg_tg.arn}"]
  vpc_zone_identifier  = data.aws_subnets.GetSubnet.ids
  launch_template {
    id      = aws_launch_template.proving_asg_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "proving-autoscaling-group"
    propagate_at_launch = true
  }
}

#Create Auto Scaling Group for ASG 2
resource "aws_autoscaling_group" "proving_asg_2" {
  min_size             = var.proving_asg_min_size
  max_size             = var.proving_asg_max_size
  desired_capacity     = var.proving_desired_capacity
  target_group_arns    = ["${aws_lb_target_group.proving_asg_tg.arn}"]
  vpc_zone_identifier  = data.aws_subnets.GetSubnet.ids
  launch_template {
    id      = aws_launch_template.proving_asg_lt_2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "proving-autoscaling-group-2"
    propagate_at_launch = true
  }
}

