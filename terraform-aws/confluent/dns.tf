resource "aws_route53_zone" "private" {
  #name = "${var.name}-private-zone"
  name = "aws.${var.ownershort}.cp.com."
  vpc {
    vpc_id = data.aws_vpc.default.id
  }
  tags = {
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
  }
}

resource "aws_route53_record" "broker" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "ak${count.index}.${aws_route53_zone.private.name}"
  type    = "A"
  ttl     = "300"
  count   = var.broker-count
  records = [aws_instance.brokers[count.index].public_ip]
}

resource "aws_route53_record" "zookeeper" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "zk${count.index}.${aws_route53_zone.private.name}"
  type    = "A"
  ttl     = "300"
  count   = var.zk-count
  records = [aws_instance.zookeeper[count.index].public_ip]
}
