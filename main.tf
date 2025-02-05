provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "ocp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ocp-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ocp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ocp-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ocp_vpc.id
  tags = {
    Name = "ocp-igw"
  }
}

# Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ocp_vpc.id
  tags = {
    Name = "public-route-table"
  }
}

# Create Route for Internet Access
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create Security Group for SSH Access
resource "aws_security_group" "ssh_sg" {
  name        = "ssh-access"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.ocp_vpc.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
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
    Name = "ssh-access"
  }
}

# Variable for Key Pair name (should exist in AWS)
variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
  default     = "my-keypair"
}

# Launch Amazon Linux Instance
resource "aws_instance" "amazon_linux" {
  ami                         = "ami-0c614dee691cbbf37"  # Replace with the correct Amazon Linux 2 AMI ID
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ssh_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "amazon-linux-instance"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  description = "The public IP of the Amazon Linux instance"
  value       = "ssh -i my-keypair.pem ec2-user@${aws_instance.amazon_linux.public_ip}"
}