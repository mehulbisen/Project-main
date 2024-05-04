provider "aws" {
    region = "eu-west-1"
}

# Creating VPC
resource "aws_vpc" "project_vpc" {
    cidr_block = "10.0.0.0/16"
}

# Creating Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.project_vpc
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.project_vpc
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
    cidr_block = "0.0.0.0/0"  # Route all traffic to the internet
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
