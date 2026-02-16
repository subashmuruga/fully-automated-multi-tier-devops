terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# ---------------- VPC ----------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "DevOps-VPC"
  }
}

# ---------------- Public Subnets ----------------

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "DevOps-Public-Subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "DevOps-Public-Subnet-2"
  }
}

# ---------------- Private Subnets ----------------

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "DevOps-Private-Subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "DevOps-Private-Subnet-2"
  }
}

# ---------------- Internet Gateway ----------------

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "DevOps-IGW"
  }
}

# ---------------- Route Table ----------------

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "DevOps-RouteTable"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt.id
}

# ---------------- Security Groups ----------------

# EC2 Security Group
resource "aws_security_group" "web_sg" {
  name   = "DevOps-EC2-SG"
  vpc_id = aws_vpc.main.id

  # Frontend (3000) from ALB
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Backend (5000) from ALB
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps-EC2-SG"
  }
}


# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name   = "alb-security-group"
  vpc_id = aws_vpc.main.id

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

  tags = {
    Name = "DevOps-ALB-SG"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps-RDS-SG"
  }
}

# ---------------- IAM Profile ----------------

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-profile"
  role = "ec2-ecr-role"
}

# ---------------- EC2 Instance ----------------

resource "aws_instance" "web" {
  ami                         = "ami-0f5ee92e2d63afc18"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = "devops-key-new"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y docker.io awscli

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu

# Login to ECR
aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin 700558745882.dkr.ecr.ap-south-1.amazonaws.com

# Pull Images
docker pull 700558745882.dkr.ecr.ap-south-1.amazonaws.com/multi-tier-backend:latest
docker pull 700558745882.dkr.ecr.ap-south-1.amazonaws.com/multi-tier-frontend:latest

# Run Backend (Port 5000)
docker run -d --name backend -p 5000:5000 \
-e DB_HOST=${aws_db_instance.mysql.address} \
-e DB_USER=admin \
-e DB_PASSWORD=Admin123 \
-e DB_NAME=devopsdb \
700558745882.dkr.ecr.ap-south-1.amazonaws.com/multi-tier-backend:latest

# Run Frontend (Port 3000)
docker run -d --name frontend -p 3000:80 \
700558745882.dkr.ecr.ap-south-1.amazonaws.com/multi-tier-frontend:latest
EOF


  tags = {
    Name = "DevOps-EC2"
  }
}

# ---------------- ALB ----------------

resource "aws_lb" "app_alb" {
  name               = "devops-alb"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "DevOps-ALB"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "devops-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web.id
  port             = 3000
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ---------------- RDS ----------------

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "devops-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

resource "aws_db_instance" "mysql" {
  identifier             = "devops-mysql"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "devopsdb"
  username               = "admin"
  password               = "Admin12345"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "DevOps-MySQL"
  }
}
