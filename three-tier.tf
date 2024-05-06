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

# Creating Private Subnet1
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = "10.0.18.0/24"
  tags = {
    Name = "private_subnet"
  }
}

# Creating Private Subnet2
resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = "10.0.44.0/24"
  tags = {
    Name = "private_subnet2"
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
  route_table_id = aws_route_table.private_route_table.id
}

# Associate Route Table with subnet2
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
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

# Creating RDS Subnet Group
resource "aws_db_subnet_group" "project_subnet_group" {
  name       = "project-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet2.id]
}

# Creating RDS 
resource "aws_db_instance" "my_rds_instance" {
  identifier             = "my-rds-instance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql" 
  engine_version         = "5.7"
  instance_class         = "db.t3.micro" 
  username               = "admin"
  password               = "redhat12345"
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.project_security_group.id]
  publicly_accessible    = false 
  db_subnet_group_name = aws_db_subnet_group.project_subnet_group.name
}

# Application_server_instance
resource "aws_instance" "Application_server" {
  ami           = "ami-0dfdc165e7af15242"  
  instance_type = "t2.micro"     
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = "ireland-m"
  vpc_security_group_ids = [aws_security_group.project_security_group.id]
  user_data = <<EOF
#!/bin/bash
yum install java-1.8.0-amazon-corretto -y
cd /opt/
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.88/bin/apache-tomcat-9.0.88.tar.gz
tar -xzf apache-tomcat-9.0.88.tar.gz 
cd /opt/apache-tomcat-9.0.88/webapps/
wget https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war
cd /opt/apache-tomcat-9.0.88/lib/
wget https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar
cd /opt/apache-tomcat-9.0.88/bin/
./catalina.sh start
sleep 5
./catalina.sh stop
sleep 5
./catalina.sh start

EOF

  tags = {
    Name = "App_server_instance"
  }
}

# Frontend_Server
resource "aws_instance" "Frontend_Server" {
  ami           = "ami-0dfdc165e7af15242"  
  instance_type = "t2.micro"     
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = "ireland-m"
  vpc_security_group_ids = [aws_security_group.project_security_group.id]
  user_data = <<EOF
#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl enable httpd

EOF


  tags = {
    Name = "frontend_server_instance"
  }
}

# Database_Server
resource "aws_instance" "Database_Server" {
  ami           = "ami-0dfdc165e7af15242"  
  instance_type = "t2.micro"     
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = "ireland-m"
  vpc_security_group_ids = [aws_security_group.project_security_group.id]
  user_data = <<EOF
#!/bin/bash
dnf install mariadb105-server -y
systemctl start mariadb
systemctl enable mariadb

EOF

  tags = {
    Name = "database_server_instance"
  }
}

