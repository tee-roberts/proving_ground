variable "AWS_REGION" {
  default = "us-east-2"
}

variable "image_id" {
  type    = string
  default = "ami-00d39ed1eafd91b43"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "proving_asg_min_size" {
  type    = number
  default = 1
}

variable "proving_asg_max_size" {
  type    = number
  default = 1
}

variable "proving_desired_capacity" {
  type    = number
  default = 1
}

variable "key_name" {
  type    = string
  default = "tr_key"
}

data "aws_vpc" "GetVPC" {
  filter {
    name   = "tag:Name"
    values = ["Proving_Ground"]
  }
}

data "aws_subnets" "GetSubnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.GetVPC.id]
  }
  filter {
    name   = "tag:Name"
    values = ["Proving_Ground"]
  }
}
