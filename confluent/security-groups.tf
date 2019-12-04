resource "aws_security_group" "bastions" {
  name = "${var.ownershort}-bastions"
  # description = "follower-cluster - Managed by Terraform"
  # description = "follower-cluster"

  # Allow ping from my ip
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["${local.myip-cidr}"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      self = true
      #cidr_blocks = ["${local.myip-cidr}"]
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  description = "Managed by Terraform"
  name = "${var.ownershort}-ssh"

  # Allow ping from my ip and self
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    self = true
    cidr_blocks = ["${local.myip-cidr}"]
  }

  # ssh from me and self
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
  }

  # from bastion
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      security_groups = ["${aws_security_group.bastions.id}"]
  }

  # ssh from anywhere
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "brokers" {
  description = "brokers - Managed by Terraform"
  name = "${var.ownershort}-brokers"

   # cluster
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

   #allow clients from anywhere - temporary for follower cluster in frankfurt - should get their submet range from terraform
   #9092-9095 for all broker protocols
   #ingress {
  #    from_port = 9092
#      to_port = 9096
#      protocol = "TCP"
#      cidr_blocks = ["${aws_instance.bastion.public_ip}/32"]
#  }

  # client connections from ssh hosts, connect, my ip, clients
  ingress {
      from_port = 9092
      to_port = 9092
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
      security_groups = ["${aws_security_group.bastions.id}","${aws_security_group.ssh.id}", "${aws_security_group.connect.id}", "${aws_security_group.schema-registry.id}"] # should an explicit group for clients, ssh covers it
  }

  # monitoring connections - jmx_exporter (from ssh hosts, bastion and myip)
  ingress {
      from_port = 9100
      to_port = 9100
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
      security_groups = ["${aws_security_group.bastions.id}","${aws_security_group.ssh.id}","${aws_security_group.tools.id}"]
  }

  # monitoring connections - node_exporter (from ssh hosts, bastion and myip)
  ingress {
      from_port = 9101
      to_port = 9101
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
      security_groups = ["${aws_security_group.bastions.id}","${aws_security_group.ssh.id}","${aws_security_group.tools.id}"]
  }

  # Allow ping from my ip, self, bastion
  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    self = true
    security_groups = ["${aws_security_group.bastions.id}"]
    cidr_blocks = ["${local.myip-cidr}"]
  }

  # from bastion
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      security_groups = ["${aws_security_group.bastions.id}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "zookeepers" {
  description = "Zookeeper security group - Managed by Terraform"
  name = "${var.ownershort}-zookeepers"

  ingress {
      from_port = 2181
      to_port = 2181
      protocol = "TCP"
      security_groups = ["${aws_security_group.brokers.id}", "${aws_security_group.connect.id}"]
      cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
  }

  ingress {
      from_port = 2888
      to_port = 2888
      protocol = "TCP"
      self = true
  }

  # monitoring connections - jmx_exporter (from ssh hosts, bastion and myip)
  ingress {
      from_port = 9100
      to_port = 9100
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
      security_groups = ["${aws_security_group.bastions.id}","${aws_security_group.ssh.id}","${aws_security_group.tools.id}"]
  }

  # monitoring connections - node_exporter (from ssh hosts, bastion and myip)
  ingress {
      from_port = 9101
      to_port = 9101
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
      security_groups = ["${aws_security_group.bastions.id}","${aws_security_group.ssh.id}","${aws_security_group.tools.id}"]
  }


  ingress {
      from_port = 3888
      to_port = 3888
      protocol = "TCP"
      self = true
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "c3" {
  description = "C3 security group - Managed by Terraform"
  name = "${var.ownershort}-c3"

  # web ui
  ingress {
      from_port = 9021
      to_port = 9021
      protocol = "TCP"
      cidr_blocks = ["${local.myip-cidr}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tools" {
  description = "Tools security group - Managed by Terraform"
  name = "${var.ownershort}-tools"

  # web ui
  ingress {
      from_port = 9021
      to_port = 9021
      protocol = "TCP"
      cidr_blocks = ["${local.myip-cidr}"]
  }

# prometheus web ui
  ingress {
      from_port = 9090
      to_port = 9090
      protocol = "TCP"
      cidr_blocks = ["${local.myip-cidr}"]
  }

# grafana web ui
  ingress {
      from_port = 3000
      to_port = 3000
      protocol = "TCP"
      cidr_blocks = ["${local.myip-cidr}"]
  }


  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "connect" {
  description = "Connect security group - Managed by Terraform"
  name = "${var.ownershort}-connect"

  # connect http interface - only accessable on host, without this
  # c3 needs access
  ingress {
      from_port = 8083
      to_port = 8083
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
      security_groups = ["${aws_security_group.c3.id}", "${aws_security_group.ssh.id}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "schema-registry" {
  description = "Schema Registry security group - Managed by Terraform"
  name = "${var.ownershort}-schema-registry"

  # connect http interface - only accessible on host, without this
  # schema-registry needs access
  ingress {
      from_port = 8081
      to_port = 8081
      protocol = "TCP"
      self = true
      cidr_blocks = ["${local.myip-cidr}"]
      security_groups = ["${aws_security_group.c3.id}", "${aws_security_group.ssh.id}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
