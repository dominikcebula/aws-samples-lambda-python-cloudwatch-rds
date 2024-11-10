resource "aws_vpc_endpoint" "monitoring" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.monitoring"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.lambda_subnet_a.id, aws_subnet.lambda_subnet_b.id, aws_subnet.lambda_subnet_c.id]
}

resource "aws_subnet" "lambda_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "Lambda Subnet A"
  }
}

resource "aws_subnet" "lambda_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "Lambda Subnet B"
  }
}

resource "aws_subnet" "lambda_subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "Lambda Subnet C"
  }
}

resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-"

  vpc_id = aws_vpc.vpc.id

  egress {
    from_port = 1
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lambda SG"
  }
}
