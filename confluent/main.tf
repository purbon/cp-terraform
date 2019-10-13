variable "name" {}
variable "region" {}
variable "owner" {}
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
  version = "~> 2.27"
  region = "${var.region}"
}

variable "key_name" {}

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

# T2 Medium t2.medium 4.0 GiB 2 vCPUs for a 4h 48m burst  EBS only  Low to Moderate $0.050000 hourly
# T2 Large  t2.large  8.0 GiB 2 vCPUs for a 7h 12m burst  EBS only  Low to Moderate $0.100800 hourly
# M5 General Purpose Double Extra Large m5.2xlarge  32.0 GiB  8 vCPUs EBS only  High  $0.428000 hourly

# # moderatly high performance images
# locals {
#   bastion-instance-type = "t2.2xlarge"
#   zk-instance-type = "i3.large" # I3 High I/O Large i3.large  15.25 GiB 2 vCPUs 475 GiB NVMe SSD  Up to 10 Gigabit  $0.172000 hourly
#   # c5.2xlarge not available in c4
#   # connect-instance-type = "c5.2xlarge" # C5 High-CPU Double Extra Large c5.2xlarge  16.0 GiB  8 vCPUs EBS only  Up to 10 Gbps $0.384000 hourly\
#   connect-instance-type = "c4.2xlarge"  # C4 High-CPU Double Extra Large c4.2xlarge  15.0 GiB  8 vCPUs EBS only  High  $0.454000 hourly
#   broker-instance-type = "r4.2xlarge" # 61.0 GiB  8 vCPUs EBS only  Up to 10 Gigabit $0.593000 hourly
#   c3-instance-type = "i3.4xlarge"  # 122.0 GiB 16 vCPUs  3800 GiB (2 * 1900 GiB NVMe SSD)  Up to 10 Gigabit  $1.376000 hourly
#   client-instance-type = "r4.large" # R4 High-Memory Large  r4.large  15.25 GiB 2 vCPUs EBS only  Up to 10 Gigabit  $0.148000 hourly
# }

# testing instance sizes - t2.medium 4.0 GiB 2 vCPUs for a 4h 48m burst  EBS only  Low to Moderate $0.050000 hourly
locals {
  bastion-instance-type = "t2.large"
  zk-instance-type = "t2.large"
  connect-instance-type = "t2.large"
  broker-instance-type = "t2.large"
  c3-instance-type = "t2.large"
  client-instance-type = "t2.large"
  tools-instance-type = "t2.large"
}

locals {
  brokers-eu-west-one = "0.0.0.0/0" # need to lock this down
  brokers-eu-central-one = "0.0.0.0/0" # need to lock this down
  brokers-all = "0.0.0.0/0" # need to lock this down
}

variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
}

variable "myip" { }
locals {
  myip-cidr = "${var.myip}/32"
}


# resource "aws_eip" "bastion" {
#   instance = "${aws_instance.bastion.0.id}"
#   vpc      = true
# }

# resource "aws_eip" "broker-0" {
#   instance = "${aws_instance.brokers.0.id}"
#   vpc      = true
# }

# resource "aws_eip" "zookeeper-0" {
#   instance = "${aws_instance.zookeeper.0.id}"
#   vpc      = true
# }


resource "aws_instance" "bastion" {
  #count = 1
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${local.bastion-instance-type}"
  availability_zone = "${element(var.azs, 0)}"
  security_groups = ["${aws_security_group.bastions.name}"]
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.ownershort}-bastion"
    description = "bastion node - Managed by Terraform"
    nice-name = "bastion-0"
    big-nice-name = "bastion-0"
    role = "bastion"
    Role = "bastion"
    owner = "${var.owner}"
    sshUser = "ubuntu"
    # ansible_python_interpreter = "/usr/bin/python3"
  }
}

resource "aws_instance" "tools" {
  #count = 1
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${local.tools-instance-type}"
  availability_zone = "${element(var.azs, 0)}"
  security_groups = ["${aws_security_group.tools.name}", "${aws_security_group.ssh.name}"]
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.ownershort}-tools"
    description = "tools node - Managed by Terraform"
    nice-name = "tools"
    big-nice-name = "tools"
    Role = "tools"
    owner = "${var.owner}"
    sshUser = "ubuntu"
    # ansible_python_interpreter = "/usr/bin/python3"
  }
}

resource "aws_instance" "brokers" {
  count         = "${var.broker-count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${local.broker-instance-type}"
  availability_zone = "${element(var.azs, count.index)}"
  # security_groups = ["${var.security_group}"]
  security_groups = ["${aws_security_group.brokers.name}", "${aws_security_group.ssh.name}"]
  key_name = "${var.key_name}"
  root_block_device {
    volume_size = 1000 # 1TB
  }
  tags = {
    Name = "${var.ownershort}-broker-${count.index}-${element(var.azs, count.index)}"
    description = "broker nodes - Managed by Terraform"
    nice-name = "kafka-${count.index}"
    big-nice-name = "follower-kafka-${count.index}"
    brokerid = "${count.index}"
    role = "broker"
    Role = "broker"
    owner = "${var.owner}"
    sshUser = "ubuntu"
    # sshPrivateIp = true // this is only checked for existence, not if it's true or false by terraform.py (ati)
    createdBy = "terraform"
    # ansible_python_interpreter = "/usr/bin/python3"
    #EntScheduler = "mon,tue,wed,thu,fri;1600;mon,tue,wed,thu;fri;sat;0400;"
    region = "${var.region}"
    #role_region = "brokers-${var.region}"
  }
}

resource "aws_instance" "zookeeper" {
  count         = "${var.zk-count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${local.zk-instance-type}"
  availability_zone = "${element(var.azs, count.index)}"
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.zookeepers.name}"]
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.ownershort}-zookeeper-${count.index}-${element(var.azs, count.index)}"
    description = "zookeeper nodes - Managed by Terraform"
    role = "zookeeper"
    Role = "zookeeper"
    zookeeperid = "${count.index}"
    Owner = "${var.owner}"
    sshUser = "ubuntu"
    region = "${var.region}"
    #role_region = "zookeepers-${var.region}"
  }
}

resource "aws_instance" "connect-cluster" {
  count         = "${var.connect-count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${local.connect-instance-type}"
  availability_zone = "${element(var.azs, count.index)}"
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.connect.name}"]
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.ownershort}-connect-${count.index}-${element(var.azs, count.index)}"
    description = "Connect nodes - Managed by Terraform"
    role = "connect"
    Role = "connect"
    Owner = "${var.owner}"
    sshUser = "ubuntu"
    region = "${var.region}"
    #role_region = "connect-${var.region}"
  }
}

resource "aws_instance" "control-center" {
  count         = "${var.c3-count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${local.c3-instance-type}"
  availability_zone = "${element(var.azs, count.index)}"
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.c3.name}"]
  key_name = "${var.key_name}"
  root_block_device {
    volume_size = 300 # 300 GB
  }
  tags = {
    Name = "${var.ownershort}-c3-${count.index}-${element(var.azs, count.index)}"
    description = "Control Center - Managed by Terraform"
    role = "c3"
    Role = "c3"
    owner = "${var.owner}"
    sshUser = "ubuntu"
    createdBy = "terraform"
    region = "${var.region}"
    #role_region = "c3-${var.region}"
  }
}


// Output
output "public_ips" {
  value = ["${aws_instance.brokers.*.public_ip}"]
}
output "public_dns" {
  value = ["${aws_instance.brokers.*.public_dns}"]
}
output "bastion_ip" {
  value = ["${aws_instance.bastion.public_dns}"]
}



// clients
variable "producer-count" {
  default = 2
}
variable "client-instance-type" {
  default = "t2.small"
}

variable "consumer-count" {
  default = 2
}
variable "consumer-instance-type" {
  default = "t2.small"
}
