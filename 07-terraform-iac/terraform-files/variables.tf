variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair to attach to the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_source_cidr" {
  description = "CIDR allowed to SSH into the instance - restrict this to your IP in production/real use"
  type        = string
  default     = "0.0.0.0/0"
}
