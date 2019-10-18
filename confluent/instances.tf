
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

resource "aws_volume_attachment" "brokers-ebs_attachment" {
  count         = "${var.broker-count}"
  device_name = "/dev/sda2"
  volume_id   = aws_ebs_volume.brokers[count.index].id
  instance_id =  aws_instance.brokers[count.index].id
  skip_destroy = true
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

resource "aws_instance" "proxy" {
  count = 2
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${local.proxy-instance-type}"
  availability_zone = "${element(var.azs, 0)}"
  security_groups = ["${aws_security_group.proxy.name}", "${aws_security_group.ssh.name}"]
  key_name = "${var.key_name}"
  tags = {
    Name = "${var.ownershort}-webactions-proxy-${count.index}-${element(var.azs, count.index)}"
    description = "Webactions proxy node - Managed by Terraform"
    nice-name = "proxy"
    big-nice-name = "proxy"
    Role = "proxy"
    owner = "${var.owner}"
    sshUser = "ubuntu"
    # ansible_python_interpreter = "/usr/bin/python3"
  }
}

## Proxy load balancers

resource "aws_s3_bucket" "load-balancer-logs" {
  bucket = "${var.ownershort}-logs-bucket"
  acl    = "private"
  policy = data.aws_iam_policy_document.logs.json

  tags = {
    Name = "${var.ownershort}-webactions-proxy-s3-bucket"
    description = "Webactions proxy s3 bucket - Managed by Terraform"
  }
}

# Create a new load balancer
resource "aws_elb" "proxy-load-balancer" {
  name               = "${var.ownershort}-proxy-load-balancer"
  availability_zones = var.azs
  security_groups = ["${aws_security_group.lb.id}", "${aws_security_group.proxy.id}"]

 access_logs {
    bucket        = "${var.ownershort}-logs-bucket"
    bucket_prefix = "webactions-logs"
    interval      = 60
  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = tolist(data.aws_instances.proxies.ids)
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.ownershort}-proxy-elastic-load-balancer"
  }
}
