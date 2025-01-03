provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "ec2_s3_readonly" {
  name               = "EC2-S3-ReadOnly-Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.ec2_s3_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-s3-readonly"
  role = aws_iam_role.ec2_s3_readonly.name
}


resource "aws_instance" "http_service" {
  ami           = "ami-021e165d8c4ff761d" 
  instance_type = "t2.micro"              
  key_name      = "webserver"             
  security_groups = [aws_security_group.http_access.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3 pip
              pip3 install flask boto3
              cat <<EOT >> /home/ec2-user/app.py
              ${file("code.py")}
              EOT
              python3 /home/ec2-user/app.py &
              EOF

  tags = {
    Name = "terraform-task"
  }
}


resource "aws_security_group" "http_access" {
  name        = "http-app-sg"
  description = "allow http & ssh"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
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
}

output "ec2_public_ip" {
  value       = aws_instance.http_service.public_ip
  description = "ec2 public ip  "
}

output "copy_paste_this" {
  value       = "http://${aws_instance.http_service.public_ip}:5000/list-bucket-content"
  description = "for checking "
}