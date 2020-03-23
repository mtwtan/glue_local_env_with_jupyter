# AWS Config

variable "aws_region" {
  default = "us-east-2"
}

variable "aws_key_name" {
  default = "aws-matt-ohio-east-2"
}

variable "subnet_id" {
  default = "subnet-00b47873fd7d8e7c1"
}

variable "vpc_security_group_ids" {
  default = [ "sg-0d83c380bf4a97c78" ]
}

variable "iam_instance_profile" {
  default = "SparkStandAlone"
}
