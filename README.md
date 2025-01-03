# **HTTP Service with Terraform Deployment**

This repository demonstrates the implementation of an HTTP service that interacts with an AWS S3 bucket to list its contents, along with automated deployment using Terraform.

---

## **Overview**

### **Part 1: HTTP Service**
- **Framework**: Flask
- **AWS SDK**: Boto3
- **Functionality**:
  - Exposes an endpoint to list S3 bucket contents.
  - Handles paths to provide subdirectory and file listings.
  - Returns data in JSON format.
  
### **Part 2: Terraform Deployment**
- Provisions AWS infrastructure:
  - **EC2 Instance**: Hosts the HTTP service.
  - **IAM Role & Policies**: Grants read-only access to the S3 bucket.
  - **Security Groups**: Allows HTTP (port 5000) and SSH (port 22) access.
- Automates HTTP service deployment on the EC2 instance.

---


### **Prerequisites**
- AWS CLI installed and configured.
- Terraform installed on your machine.
- An AWS Key Pair for EC2 access.

### **Deployment to AWS using Terraform**
The service is designed to be deployed on an EC2 instance. The necessary AWS resources (IAM role, ec2, security group) are provisioned using Terraform.
Run the following Terraform commands to deploy:
terraform init
terraform apply
After Terraform completes, it will output the public IP of the EC2 instance. You can access the service via this IP on port 5000(already given url to copy paste in terraform output)  http://<EC2_Public_IP>:5000/list-bucket-content

Terraform Resources created:

IAM Role: Provides read-only access to the S3 bucket(given in terraform).
EC2 Instance: Deploys the Flask app with all necessary dependencies.
Security Group: Allows HTTP (port 5000) and SSH (port 22) access to the EC2 instance.
Error Handling: The service gracefully handles invalid or non-existing paths by returning a 404 error with an appropriate message. In case of unexpected errors, a 500 internal server error is returned.


