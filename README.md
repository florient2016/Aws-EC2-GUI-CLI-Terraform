# 🚀 Deploy Amazon Linux on AWS (GUI, AWS CLI, Terraform)

This guide provides step-by-step instructions to deploy an **Amazon Linux** instance on AWS using **three methods**:

1. **AWS Management Console (GUI)**
2. **AWS CLI**
3. **Terraform**

## 📌 What This Guide Covers
✅ Create a **VPC**  
✅ Create a **Public Subnet**  
✅ Configure a **Route Table** with an **Internet Gateway**  
✅ Set up **Ingress Rules (Security Group) for SSH Access**  
✅ Create an **EC2 Key Pair**  
✅ Launch an **Amazon Linux Instance**  
✅ **Test SSH Connectivity**  

---

## 📎 Prerequisites
Before proceeding, make sure you have:

| Prerequisite         | Description |
|----------------------|-------------|
| **AWS Account**      | Sign up at [AWS](https://aws.amazon.com/) |
| **AWS CLI Installed** | [Download AWS CLI](https://aws.amazon.com/cli/) |
| **Terraform Installed** | [Install Terraform](https://developer.hashicorp.com/terraform/downloads) |
| **Configured AWS CLI Credentials** | Run `aws configure` |

---

# 1️⃣ Deploy Using **AWS Management Console (GUI)**

## 🏗️ Step 1: Create a VPC
1. Open **AWS Console** → **VPC**.
2. Click **Create VPC**.
3. Set:
   - **Name**: `my-vpc`
   - **IPv4 CIDR**: `10.0.0.0/16`
4. Click **Create VPC**.

## 📡 Step 2: Create a Public Subnet
1. Navigate to **VPC** → **Subnets** → **Create Subnet**.
2. Select **VPC**: `my-vpc`.
3. Set:
   - **Name**: `public-subnet`
   - **CIDR**: `10.0.1.0/24`
   - **Availability Zone**: Choose one (e.g., `us-east-1a`).
4. **Enable Auto-assign Public IP**.
5. Click **Create Subnet**.

## 🛣️ Step 3: Create a Route Table
1. Navigate to **VPC** → **Route Tables** → **Create Route Table**.
2. Set:
   - **Name**: `public-route-table`
   - **VPC**: `my-vpc`
3. Click **Create**.
4. Select **public-route-table**, go to **Routes** → **Edit Routes**.
5. Add:
   - **Destination**: `0.0.0.0/0`
   - **Target**: Internet Gateway (Create one if needed)
6. Go to **Subnet Associations** and associate with **public-subnet**.

## 🔐 Step 4: Create a Security Group for SSH Access
1. Navigate to **EC2** → **Security Groups** → **Create Security Group**.
2. Set:
   - **Name**: `ssh-access`
   - **VPC**: `my-vpc`
3. Add **Inbound Rule**:
   - **Type**: `SSH`
   - **Protocol**: `TCP`
   - **Port**: `22`
   - **Source**: `0.0.0.0/0`
4. Click **Create Security Group**.

## 🔑 Step 5: Create a Key Pair
1. Navigate to **EC2** → **Key Pairs** → **Create Key Pair**.
2. Set:
   - **Name**: `my-keypair`
   - **Format**: `.pem` (For SSH)
3. Click **Create Key Pair** and **Download**.

## 🖥️ Step 6: Launch an Amazon Linux Instance
1. Navigate to **EC2** → **Launch Instance**.
2. Choose **Amazon Linux 2 AMI**.
3. Select **t2.micro** (Free tier).
4. Set:
   - **VPC**: `my-vpc`
   - **Subnet**: `public-subnet`
   - **Security Group**: `ssh-access`
   - **Key Pair**: `my-keypair`
5. Click **Launch**.

## 🏁 Step 7: Test SSH Connectivity
```sh
chmod 400 my-keypair.pem
ssh -i my-keypair.pem ec2-user@<Public-IP>

# 2️⃣ Deploy Using **AWS CLI**

Run the following commands, replacing **IDs** as needed.

## 🏗️ Step 1: Create VPC
```sh
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-vpc}]'
```
## 📡 Step 2: Create Public Subnet
```sh
aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 --availability-zone us-east-1a
```
## 🛣️ Step 3: Create Internet Gateway & Route Table
```sh
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway --vpc-id <vpc-id> --internet-gateway-id <igw-id>

aws ec2 create-route-table --vpc-id <vpc-id> --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public-route-table}]'
aws ec2 create-route --route-table-id <rtb-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <igw-id>
aws ec2 associate-route-table --subnet-id <subnet-id> --route-table-id <rtb-id>
```
## 🔐 Step 4: Create Security Group for SSH Access
```sh
aws ec2 create-security-group --group-name ssh-access --description "Allow SSH access" --vpc-id <vpc-id>

aws ec2 authorize-security-group-ingress \
    --group-id <sg-id> \
    --protocol tcp --port 22 \
    --cidr 0.0.0.0/0
```
## 🔑 Step 4: Create Key Pair
```sh
aws ec2 create-key-pair --key-name my-keypair --query 'KeyMaterial' --output text > my-keypair.pem
chmod 400 my-keypair.pem
```
## 🖥️ Step 5: Launch Amazon Linux Instance
```sh
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --count 1 \
    --instance-type t2.micro \
    --key-name my-keypair \
    --security-group-ids <sg-id> \
    --subnet-id <subnet-id> \
    --associate-public-ip-address
```

## 🏁 Step 7: Test SSH Connectivity
```sh
ssh -i my-keypair.pem ec2-user@<Public-IP>
```

# 3️⃣ Deploy Using Terraform

🏗️ main.tf Configuration
```sh
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

# Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
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
  vpc_id      = aws_vpc.my_vpc.id

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
  ami                         = "ami-0abcdef1234567890"  # Replace with the correct Amazon Linux 2 AMI ID
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
  value       = aws_instance.amazon_linux.public_ip
}
```

## 🏁 Terraform Commands
```sh
terraform init
terraform apply
```

## 🏁 Test SSH Connectivity
```sh
ssh -i my-keypair.pem ec2-user@<Public-IP>
```

# 🎉 Conclusion
You now have three different ways to deploy Amazon Linux on AWS:

GUI (AWS Management Console)
AWS CLI (Command-line)
Terraform (Infrastructure as Code)




