
resource "aws_instance" "bastion" {
  #count = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.bastion-instance-type
  availability_zone = element(var.azs, 0)
  security_groups = ["${aws_security_group.bastions.name}"]
  key_name = var.key_name
  tags = {
    Name = "${var.ownershort}-bastion"
    description = "bastion node - Managed by Terraform"
    nice-name = "bastion-0"
    big-nice-name = "bastion-0"
    role = "bastion"
    Role = "bastion"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
    sshUser = "ubuntu"
    # ansible_python_interpreter = "/usr/bin/python3"
  }
}

resource "aws_instance" "tools" {
  #count = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type =  local.tools-instance-type
  availability_zone = element(var.azs, 0)
  security_groups = ["${aws_security_group.tools.name}", "${aws_security_group.ssh.name}"]
  key_name = var.key_name
  tags = {
    Name = "${var.ownershort}-tools"
    description = "tools node - Managed by Terraform"
    nice-name = "tools"
    big-nice-name = "tools"
    Role = "tools"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
    sshUser = "ubuntu"
    # ansible_python_interpreter = "/usr/bin/python3"
  }
}

resource "aws_instance" "brokers" {
  count         = var.broker-count
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.broker-instance-type
  availability_zone = element(var.azs, count.index)
  # security_groups = ["${var.security_group}"]
  security_groups = ["${aws_security_group.brokers.name}", "${aws_security_group.ssh.name}"]
  key_name = var.key_name
  root_block_device {
    volume_size = 1000 # 1TB
  }
  tags = {
    Name = "${var.ownershort}-broker-${count.index}-${element(var.azs, count.index)}"
    description = "broker nodes - Managed by Terraform"
    nice-name = "kafka-${count.index}"
    big-nice-name = "follower-kafka-${count.index}"
    brokerid = count.index
    role = "broker"
    Role = "broker"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
    sshUser = "ubuntu"
    # sshPrivateIp = true // this is only checked for existence, not if it's true or false by terraform.py (ati)
    createdBy = "terraform"
    # ansible_python_interpreter = "/usr/bin/python3"
    #EntScheduler = "mon,tue,wed,thu,fri;1600;mon,tue,wed,thu;fri;sat;0400;"
    region = var.region
    #role_region = "brokers-${var.region}"
  }
}

#resource "aws_volume_attachment" "brokers-ebs_attachment" {
#  count         = var.broker-count
#  device_name = "/dev/sda2"
#  volume_id   = aws_ebs_volume.brokers[count.index].id
#  instance_id =  aws_instance.brokers[count.index].id
#  skip_destroy = true
#}

resource "aws_instance" "zookeeper" {
  count         = var.zk-count
  ami           =  data.aws_ami.ubuntu.id
  instance_type = local.zk-instance-type
  availability_zone = element(var.azs, count.index)
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.zookeepers.name}"]
  key_name = var.key_name
  tags = {
    Name = "${var.ownershort}-zookeeper-${count.index}-${element(var.azs, count.index)}"
    description = "zookeeper nodes - Managed by Terraform"
    role = "zookeeper"
    Role = "zookeeper"
    zookeeperid = count.index
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
    sshUser = "ubuntu"
    region = var.region
    #role_region = "zookeepers-${var.region}"
  }
}

resource "aws_instance" "connect-cluster" {
  count         = var.connect-count
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.connect-instance-type
  availability_zone = element(var.azs, count.index)
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.connect.name}"]
  key_name = var.key_name
  tags = {
    Name = "${var.ownershort}-connect-${count.index}-${element(var.azs, count.index)}"
    description = "Connect nodes - Managed by Terraform"
    role = "connect"
    Role = "connect"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
    sshUser = "ubuntu"
    region = var.region
    #role_region = "connect-${var.region}"
  }
}

resource "aws_instance" "control-center" {
  count         = var.c3-count
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.c3-instance-type
  availability_zone = element(var.azs, count.index)
  security_groups = ["${aws_security_group.ssh.name}", "${aws_security_group.c3.name}"]
  key_name = var.key_name
  root_block_device {
    volume_size = 300 # 300 GB
  }
  tags = {
    Name = "${var.ownershort}-c3-${count.index}-${element(var.azs, count.index)}"
    description = "Control Center - Managed by Terraform"
    role = "c3"
    Role = "c3"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
    sshUser = "ubuntu"
    createdBy = "terraform"
    region = var.region
    #role_region = "c3-${var.region}"
  }
}
