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

# Creating Public Subnet2
resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.project_vpc.id
  cidr_block = "10.0.64.0/24"
  tags = {
    Name = "public_subnet2"
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
resource "aws_route_table_association" "private_route_table_association2" {
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
  skip_final_snapshot    = true
}

# Creating Load Balancer
resource "aws_lb" "Demo-ALB" {
  name               = "Demo-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.project_security_group.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet2.id]
  
  tags = {
    Name = "Demo-ALB"
  }
}

# Create a target group
resource "aws_lb_target_group" "Demo-TG" {
  name     = "Demo-TG"
  port     = 80
  protocol = "HTTP"
  
  vpc_id   = aws_vpc.project_vpc.id

}

# Attach target group to the load balancer
resource "aws_lb_listener" "demo_listener" {
  load_balancer_arn = aws_lb.Demo-ALB.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Demo-TG.arn
  }
}

# Creating Launch Template
resource "aws_launch_template" "application_launch_template" {
  name_prefix   = "Application_template"
  image_id      = "ami-0dfdc165e7af15242"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.project_security_group.id]
  key_name = "ireland-m"
}

# Creating AutoScaling Group
resource "aws_autoscaling_group" "Demo-ASG" {
  name                  = "Demo-ASG"
  min_size              = 1
  max_size              = 3
  desired_capacity      = 2
  vpc_zone_identifier   = [aws_subnet.private_subnet.id, aws_subnet.private_subnet2.id]
  target_group_arns         = [aws_lb_target_group.Demo-TG.arn]
  launch_template {
    id      = aws_launch_template.application_launch_template.id
  }
  tag {
    key                 = "Name"
    value               = "application-instance"
    propagate_at_launch = true
  }
}

# Attach target group to the load balancer
resource "aws_lb_target_group_attachment" "Demo-TG-attachment" {
  target_group_arn = aws_lb_target_group.Demo-TG.arn
  target_id        = aws_autoscaling_group.Demo-ASG.id
}