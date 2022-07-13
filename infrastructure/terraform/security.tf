resource "aws_security_group" "docker_swarm_sg" {
  vpc_id = "${var.VPC_ID}"
  name = "${var.PROJECT_NAME}_sg"
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 2376
    to_port = 2377
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 7946
    to_port = 7946
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 7946
    to_port = 7946
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 4789
    to_port = 4789
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "${var.PROJECT_NAME}-docker-swarm-sg"
  }
}
