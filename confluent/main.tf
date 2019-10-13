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
