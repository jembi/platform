locals {
  subDomainArray = split(" ", var.SUBDOMAIN_NAMES)
}

resource "aws_instance" "cdrA" {

  ami = "${lookup(var.AMI, var.AWS_REGION)}"
  instance_type = "${var.INSTANCE_TYPE}"
  count = "${var.INSTANCE_COUNT}"
  monitoring = "${var.DETAILED_MONITORING_ENABLED}"

  subnet_id = "${aws_subnet.public_subnet.id}"

  vpc_security_group_ids = [
    "${aws_security_group.ssh_allowed.id}"]

  key_name = "${aws_key_pair.key_pair.id}"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "${var.VOLUME_SIZE}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  user_data = "${file("${path.module}/scripts/ec2_init.sh")}"

  tags = {
    Name = "${var.PROJECT_NAME}"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.PROJECT_NAME}_key_pair"
  public_key = "${file(var.PUBLIC_KEY_PATH)}"
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  count = var.ALARMS_ENABLED ? var.INSTANCE_COUNT : 0
  alarm_name = "${var.PROJECT_NAME}_cpu-utilization${tostring(count.index)}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "3600"
  statistic = "Average"
  threshold = "1"
  alarm_description = "Monitor ec2 cpu for inactivity"
  insufficient_data_actions = []
  dimensions = {
    InstanceId = "${aws_instance.cdrA[count.index].id}"
  }
  alarm_actions = [
    "arn:aws:automate:${var.AWS_REGION}:ec2:stop"]
  actions_enabled = true
}

resource "aws_route53_zone" "primary" {
  count = var.DOMAIN_NAME_CREATION_ENABLED ? 1 : 0
  name = "${var.DOMAIN_NAME}"
}

resource "aws_route53_record" "domain_name" {
  count = var.DOMAIN_NAME_CREATION_ENABLED ? 1 : 0
  zone_id = aws_route53_zone.primary[0].zone_id
  name    = "${var.DOMAIN_NAME}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.cdrA[0].public_ip}"]
}

resource "aws_route53_record" "subdomains" {
  count = var.SUB_DOMAIN_NAME_CREATION_ENABLED && var.SUBDOMAIN_NAMES != "" ? length(local.subDomainArray) : 0
  zone_id = aws_route53_zone.primary[0] ? aws_route53_zone.primary[0].zone_id : var.HOSTED_ZONE_ID
  name    = "${local.subDomainArray[count.index]}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.cdrA[0].public_ip}"]
}

output "public_A_ip_-_Swarm_Leader" {
  value = "${aws_instance.cdrA[0].public_ip}"
}
# output "public_B_ip" {
#   value = "${aws_instance.cdrA[1].public_ip}"
# }
# output "public_C_ip" {
#   value = "${aws_instance.cdrA[2].public_ip}"
# }
