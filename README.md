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


