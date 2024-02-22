Terraform_Challenge_3


terraform providers 
provider[registry.terraform.io/hashicorp/aws] 4.15.0


file: variables.tf
-------------------

variable "ami" {
  type = string
  default = "ami-06178cf087598769c"
}

variable "region" {
  type = string
  default = "eu-west-2"
}

variable "instance_type" {
  type = string
  default = "m5.large"
}


file: main.tf
-------------

resource "aws_key_pair" "citadel-key" {
  key_name   = "citadel"
   public_key = file("/root/terraform-challenges/project-citadel/.ssh/ec2-connect-key.pub")
}


resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.citadel.id
  provisioner "local-exec" {
    command = "echo ${self.public_dns} >> /root/citadel_public_dns.txt"
  }
}

resource "aws_instance" "citadel" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.citadel-key.key_name
  user_data     = file("/root/terraform-challenges/project-citadel/install-nginx.sh")
}

