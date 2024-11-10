resource "aws_route_table_association" "lambda_igw_route_assoc" {
  subnet_id      = aws_subnet.lambda_subnet_public.id
  route_table_id = aws_route_table.igw_route.id
}

resource "aws_eip" "lambda_nat_gateway_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "lambda_nat_gateway" {
  allocation_id = aws_eip.lambda_nat_gateway_eip.id
  subnet_id     = aws_subnet.lambda_subnet_public.id
  tags = {
    "Name" = "Lambda NAT GW"
  }
}

resource "aws_route_table" "lambda_nat_gateway_route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lambda_nat_gateway.id
  }
}

resource "aws_route_table_association" "lambda_nat_gateway_route_assoc" {
  subnet_id      = aws_subnet.lambda_subnet_private.id
  route_table_id = aws_route_table.lambda_nat_gateway_route.id
}

resource "aws_subnet" "lambda_subnet_public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Lambda Subnet Public"
  }
}

resource "aws_subnet" "lambda_subnet_private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Lambda Subnet Private"
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
