resource "aws_subnet" "db_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "DB Subnet A"
  }
}

resource "aws_route_table_association" "db_subnet_a_route_assoc" {
  subnet_id      = aws_subnet.db_subnet_a.id
  route_table_id = aws_route_table.igw_route.id
}

resource "aws_subnet" "db_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "DB Subnet B"
  }
}

resource "aws_route_table_association" "db_subnet_b_route_assoc" {
  subnet_id      = aws_subnet.db_subnet_b.id
  route_table_id = aws_route_table.igw_route.id
}

resource "aws_subnet" "db_subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "DB Subnet C"
  }
}

resource "aws_route_table_association" "db_subnet_c_route_assoc" {
  subnet_id      = aws_subnet.db_subnet_c.id
  route_table_id = aws_route_table.igw_route.id
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block, "91.226.50.0/24"]
  }

  tags = {
    Name = "RDS SG"
  }
}
