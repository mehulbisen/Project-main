provider "aws" {
    region = "eu-west-1"
}

# Creating VPC
resource "aws_vpc" "project_vpc" {
    cidr_block = "10.0.0.0/16"
}

# Creating Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public_subnet"
  }
}

# Creating Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = "10.0.18.0/24"
  tags = {
    Name = "private_subnet"
  }
}

# Internetgateway 
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "project-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  
    gateway_id = aws_internet_gateway.project_igw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.project_vpc.id
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Elastic IP
resource "aws_eip" "project_eip" {
  domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "project_nat" {
  allocation_id = aws_eip.project_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Create Route for NAT Gateway
resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.project_nat.id
}

# Create Security Group
resource "aws_security_group" "project_security_group" {
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

