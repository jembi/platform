resource "aws_instance" "platform_instance" {
  ami = "${lookup(var.AMI, var.AWS_REGION)}"
  instance_type = "${var.INSTANCE_TYPE}"
  count = "${var.INSTANCE_COUNT}"
  monitoring = "${var.DETAILED_MONITORING_ENABLED}"

  subnet_id = "${var.SUBNET_ID}"

  vpc_security_group_ids = [
    "${aws_security_group.docker_swarm_sg.id}"]

  key_name = "${aws_key_pair.key_pair.id}"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "${var.VOLUME_SIZE}"
    volume_type = "gp2"
    delete_on_termination = true
  }

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
    InstanceId = "${aws_instance.platform_instance[count.index].id}"
  }
  alarm_actions = [
    "arn:aws:automate:${var.AWS_REGION}:ec2:stop"]
  actions_enabled = true
}

resource "aws_route53_record" "domain_name" {
  count = var.DOMAIN_NAME_CREATION_ENABLED ? 1 : 0
  zone_id = "${var.HOSTED_ZONE_ID}"
  name    = "${var.DOMAIN_NAME}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.platform_instance[0].public_ip}"]
}
resource "aws_route53_record" "subdomain" {
  count = var.SUB_DOMAIN_NAME_CREATION_ENABLED ? 1 : 0
  zone_id = "${var.HOSTED_ZONE_ID}"
  name    = "*.${var.DOMAIN_NAME}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.platform_instance[0].public_ip}"]
}

resource "aws_route53_record" "node_domain_names" {
  count = var.NODE_DOMAIN_NAME_CREATION_ENABLED ? var.INSTANCE_COUNT : 0
  zone_id = "${var.HOSTED_ZONE_ID}"
  name    = "node-${tostring(count.index+1)}.${var.DOMAIN_NAME}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.platform_instance[count.index].public_ip}"]
}

output "public_ips" {
  value = aws_instance.platform_instance[*].public_ip
}

output "domains" {
  value = {
    domain_name = length(aws_route53_record.domain_name) > 0 ? aws_route53_record.domain_name[0].name : null
    subdomain = length(aws_route53_record.subdomain) > 0 ? aws_route53_record.subdomain[*].name : null
    node_domain_names = length(aws_route53_record.node_domain_names) > 0 ? aws_route53_record.node_domain_names[*].name : null
  }
}
