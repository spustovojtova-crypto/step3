variable "aws_region" {
  type    = string
  default = "eu-central-1"
}
variable "instance_type_master" {
  type    = string
  default = "t3.small"
}
variable "instance_type_worker" {
  type    = string
  default = "t3.micro"
}
variable "public_key_path" {
  default = "/home/sveta/.ssh/id_rsa.pub"
}
variable "private_key_path" {
  default = "/home/sveta/.ssh/id_rsa"
}
variable "vpc_cidr" { 
  default = "10.0.0.0/16" 
  }
variable "public_subnet_cidr" {
   default = "10.0.10.0/24" 
   }
variable "private_subnet_cidr" {
   default = "10.0.20.0/24" 
   }
variable "key_name" {
   default = "terraform-ansible" 
   }


