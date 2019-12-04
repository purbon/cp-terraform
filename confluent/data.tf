resource "aws_ebs_volume" "brokers" {
  count             = var.broker-count
  availability_zone = element(var.azs, count.index)
  size              = 40
  encrypted         = false
  tags = {
    Name = "${var.ownershort}-ebs-broker-${count.index}-${element(var.azs, count.index)}"
    description = "EBS disk for broker nodes - Managed by Terraform"
  }
}
