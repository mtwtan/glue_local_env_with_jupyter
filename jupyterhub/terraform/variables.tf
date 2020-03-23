# AWS Config

variable "aws_region" {
  default = "<region>"
}

variable "aws_key_name" {
  default = "<AWS Key Name>"
}

variable "subnet_id" {
  default = "subnet-xxxxxxxxxxxxxxxxx"
}

variable "vpc_security_group_ids" {
  default = [ "sg-xxxxxxxxxxxxxxxxx" ]
}

variable "iam_instance_profile" {
  default = "<Instance Profile Name>"
}
