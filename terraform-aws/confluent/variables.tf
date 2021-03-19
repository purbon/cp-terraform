variable "name" {}
variable "region" {}
variable "Owner_Name" {}
variable "Owner_Email" {}
variable "ownershort" {}

variable "zk-count" {
  default = 1
}
variable "broker-count" {
  default = 1
}
variable "connect-count" {
  default = 1
}
variable "c3-count" {}

provider "aws" {
  version = "~> 3.33"
  region = var.region
}

variable "key_name" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# variable "ami" {
#   # default = "ami-57eae033" # us-west-2 ubuntu
#   # default = "ami-960316f2"
#   default = "${data.aws_ami.ubuntu.id}"
# }

# variable "instance_type" {
#   default = "t2.medium"
# }
