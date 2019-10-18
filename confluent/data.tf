resource "aws_ebs_volume" "brokers" {
  count             = "${var.broker-count}"
  availability_zone = "${element(var.azs, count.index)}"
  size              = 40
  encrypted         = false
  tags = {
    Name = "${var.ownershort}-ebs-broker-${count.index}-${element(var.azs, count.index)}"
    description = "EBS disk for broker nodes - Managed by Terraform"
  }
}



data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_elb_service_account" "this" {}


data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.arn]
    }

    resources = [
      "arn:aws:s3:::${var.ownershort}-logs-bucket/*",
    ]
  }
}

data "aws_instances" "proxies" {
  instance_tags = {
    Role = "proxy"
  }
}
