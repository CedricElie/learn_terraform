TERRAFORM 
------


How to install Terraform
-------------------------

To install terraform, download the binaries and extract them, then move them to /usr/local/bin

--brew install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

Else download this : https://releases.hashicorp.com/terraform/1.2.4/terraform_1.2.4_darwin_amd64.zip
unzip and move it to /usr/local/bin



general terraform syntax :
---------------------------

local.tf
---
<block> <parameters> {
	
	key1 = value1
	key2 = value2
}


resource "local_file" "pet" {
	filename = "/root/pets.txt"
	content = "We love pets !"
}


resource "aws_s3_bucket" "data" {
	bucket = "webserver-bucket-org-2207"
	acl = "private"
}

resource "aws_instance" "webserver" {
	ami = "ami-0c22VDF24T2"
	instance_type = "t2.micro"
}

TF workflow :

1 - Write the config file
2 - Apply the tf init command
3 - Review the execution plan, using tf plan command
4 - Apply the changes using the tf apply command


$ terraform init

$ terraform plan

$ terraform apply

$ terraform show, to view the resource we've just created

You can make use of the -auto-approve flag, during terraform apply
$ terraform apply -auto-approve


To see the details of the resources that were just created by inspecting the state files
$ terraform show
b  

update and destroy infrastructure using terraform
---------


update resrouce :

resource "local_file" "pet" {
	filename = "/root/pets.txt"
	content = "We love pets !"
	file_permission = "0700"
}

$ terraform plan

$ terraform apply


To delete the infrastructure

$ terraform destroy


configuration directory 

main.tf - main configuration containing resource definition
variables.tf - contains variable declarations
outputs.tf - contains outputs from resources
provider.tf - contains provider definition
terraform.tf - configure terraform behavior



Terraform Provider Basics
---------------------------

terraform providers are distributed by hashicorp and are publicly available at: registry.terraform.io

Type of providers :
Official 
Verified Providers 
Community Providers

plugins are downloaded in the .terraform/plugins directory

Multiple Providers :

main.tf
---

resource "local_file" "pet" {
	filename = "/root/pets.txt"
	content = "We love pets"
}

resource "random_pet" "my-pet" {
	prefix = "Mrs"
	seperator = "."
	length = "1"
}

resource "random_string" "server-suffix" {
	length = 6
	upper = false
	special = false
}

resource "aws_instance" "web" {
	ami = "ami-06178cf087598769c"
	instance_type = "m5.large"
	tags = { 
		Name = "web-${random_string.server-suffix.id}"
		   }
}
---

Rerun the $ terraform init

$ terraform init





Version constraints
-------------------

To install a provider, copy and paste this code into your Terraform configuration. Then run terraform init

terraform {
	required_providers {
	local = {
		source = "hashicorp/local"
		version = "1.4.0"
	}
	}
}

$ terraform init



version = "!= 2.0.0" -- version 2.0.0 will not be downloaded
version = "> 2.0.0"  -- version greater than 2.0.0 will be downloaded
version = "< 2.0.0"  -- version less that 2.0.0 will be downloaded
version = "> 1.2.0, < 2.0.0, != 1.4.0"
version = "~> 1.2"  -- download either 1.2 or any incremental version up to 1.X


Aliases
-------

Multiple configurations of the same provider

provider "aws" {
	region = "us-east-1"
}

provider "aws" {
	region = "ca-central-1"
	alias = "central"
}

resource "aws_key_pair" "alpha" {
	key_name = "alpha"
}

resource "aws_key_pair" "beta" {
	key_name = "beta"
	provider = aws.central
}



Variables
============

To assign a variables we make use of a variable block using the keywork variable

variables.tf
---

variable "filename" {
	default = "/root/pets.txt"
}

variable "content" {
	default = "We love pets!"
}

variable "prefix" {
	default = "Mrs"
}

variable "seperator" {
	default = "."
}

variable "length" {
	default = "1"
}

main.tf
---

resource "local_file" "pet" {
	filename = var.filename
	content = var.content
}

resource "random_pet" "my-pet" {
	prefix = var.prefix
	seperator = var.seperator
	length = var.length
}


variables can be passed through command line

$ terraform apply -var "ami=ami-0edab43b6fa892279" -var "instance_type=t2.micro"

Environment variables can also be used

$ export TF_VAR_instance_type="t2.micro"
$ terraform apply

Variables can also be declared in bulk

variables.tfvars
--
ami="ami-0edab43b6fa892279"
instance_type="t2.micro"


Automaticall loaded variable files are :

terrafor.tfvars 	terraform.tfvars.json
*.auto.tfvars 		*.auto.tfvars.json

Precedence : 
1- Environment variables
2- terraform.tfvars
3- *.auto.tfvars (alphabetical order)
4- -var or -var-file (command-line flags)




Using variables
----------------

variable types :

string
number
bool
any
list = ["web1","web2"]
map = region1 = us-east-1
	  region2 = us-west-2

object = complex data structure
tuple = complex data structure


variables.tf
---
variable "servers" {
	default = ["web1","web2","web3"]
	type 	= set(string)
}

variable "db" {
	default = ["db1","db2"]
	type 	= list
}

variable "bella" {
	type = object({
		name  = string
		color = string
		age   = number
		food  = list(string)
		favorite_pet = bool
	 			})
	default = {
  		name  = "bella"
  		color = "brown"
  		age   = 7
  		food  = ["fish","chicken","turkey"]
  		favorite_pet = true
	 }
}

main.tf
---

resource "aws_instance" "web" {
	ami 		  = var.ami
	instance_type = var.instance_type
	tags 		  = {
		name = var.server[0]
	}
}



Output variables
===========


main.tf
--

resource "aws_instance" "cerberus" {
	ami 		  = var.ami
	instance_type = var.instance_type
}

variables.tf
---

variable "ami" {
	default = "ami-87a865a4a97a"
}

variable "instance_type" {
	default = "m5.large"
}

variable "region" {
	default = "eu-west-2"
}


output.tf
---

output "pub_ip" {
	value 		= aws_instance.cerberus.public_ip
	description = "print the public IPv4 address"
}





Resource Attributes and Dependencies
--------


resource "aws_key_pair" "alpha" {
	key_name   = "alpha"
	public_key = "ssh-rsa..."
}

resource "aws_instance" "cerberus" {
	ami 		  = var.ami
	instance_type = var.instance_type
	key_name 	  = aws_key_pair.alpha.key_name
}

This is implicit dependency
reference is done by : <RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>



resource "aws_instance" "db" {
	ami 		  = var.db_ami
	instance_type = var.web_instance_type
}

resource "aws_instance" "web" {
	ami 		  = var.web_ami
	instance_type = var.db_instance_type
	depends_on 	  = [
		aws_instance.db
	]
}

This is an explicit dependency


Resource Targeting
-----------------


resource "random_string" "server-suffix" {
	length  = 6
	upper   = false
	special = false
}

resource "aws_instance" "web" {
	ami 		  = "ami-06178cf087598769c"
	instance_type = "m5.large"
	tags 		  = {
						Name = "web-${random_string.server-suffix.id}" // interpolation syntax
	}
}

Resources target tends to update a specific resource, and not the dependencies during terraform apply

$ terraform apply -target random_string.server-suffix



Data Sources
------------

data "aws_key_pair" "cerberus-key" {
	filter {
	name = "tag:project"
	values = ["cerberus"]
	}
}

resource "aws_instance" "cerberus" {
	ami 		  = var.ami
	instance_type = var.instance_type
	key_name 	  = data.aws_key_pair.cerberus-key.key_name
}






Terraform State
---------------

terraform.tfstate

main.tf
---

resource "local_file" "pet" {
	filename = "/root/pets.txt"
	content = "We love pets!"
}

terraform.tf
---

terraform {
	backend "s3" {
		bucket 		   = "kodekloud-terraform-state-bucket01"
		key    		   = "finance/terraform.tfstate"
		region 		   = "us-west-1"
		dynamodb_table = "state-locking"
	}
}

$ terraform init
This copies the new state file to the remote backend

$ rm -rf terraform.tfstate

$ terraform plan

$ terraform apply


Use the Terraform CLI
=======================


$ terraform validate

$ terraform fmt
Reads the config and formats it in a canonical format, this improves readability

$ terraform show
Show the current state of the terraform

$ terraform providers
Show all providers used in the configuration

$ terraform output

$ terraform output petname

$ terraform plan

$ terraform apply

$ terraform refresh
It is used to sync terraform with the real world setup

$ terraform graph
Use to create visual dependences and can be visualised using graph visualisation tools


$  terraform state list
This will list all resources recorded in the terraform state file

$ terraform state show aws_s3_bucket.cerberus-finance
This can be used to get specific details about a terraform resource

$ terraform state mv
this is used to move terraform resource from one state file to another

ex : $ terraform state mv aws_dynamedb_table.state-locking aws_dynamodb_table.state-locking-db
This does not change the resource name in the configuration file, it only does so in the state file
updating the terraform configurationf file must be done manually


$  terraform state pull
This is to download remote state file to local

$ terraform state rm ADDRESS
To remove a resource from state file, make sure you also remove the file manually from the configuration files
Resources removed from the state file are not really removed but just removed from terraform's management

$ terraform state push ./terraform.tfstate




Lifecycle rules
----------------

Controls how terraform creates and deletes resources.

resource "aws_instance" "cerberus" {
	ami 		  = "ami-2158cf087598787a"
	instance_type = "m5.large"
	tags		  = {
						Name = "Cerberus-Webserver"
					}
	lifecycle {
		create_before_destroy = true
		//or
		prevent_destroy = true
		//or
		ignore_changes = all
	}
}



Terraform Taint
------

This is to taint for destroy a particular terraform resource

$ terraform taint aws_instance.webserver

$ terraform plan
This is mark the resource and tainted and ready for recreate during terraform apply


To untaint a resource, we launch the following command

$ terraform untaint aws_instnace.webserver


Logging and debugging
-----------------------

# export TF_LOG=<log_level>
There are five levels : INFO, WARNING, ERROR, DEBUG, TRACE


$ export TF_LOG=TRACE

To store the logs persistently in a file, use the env variable TF_LOG_PATH

$ export TF_LOG_PATH=/tmp/terraform.log


To disable logging, unset the variables



Terraform Import
----------------

Used to bring resources created by other means into the management of terraform

Instance ID = resource_id


mail.tf
--
resource "aws_instance" "webserver-2" {
	# (resource aurguments)
}

$ terraforma import aws_instance2


Terraform workspace
-------------------

$ terraform workspace new production

main.tf
---

resource "aws_instance" %webserver" {
	ami = var.ami
	#instance_type = var.instance_type
	instance_type = lookup(var.instance_type, terraform.workspace)
	tags = {
		Environment = "-Developement"
	}
}


variables.tf
-----------

variable "ami" {
	default = "ami-24e1140119877avm"
}

variable "region" {
	default = "ca-central-1"
}

variable "instance_type" {
	type = map
	default = {
		"development" = "t2.micro"
		"production" = "m5.large"
	}
}

$ terraform console

$ terraform.workspace

$ lookup(var.instance_type,terraform.workspace)

$ terraform workspace select production

$ terraform lookup(var.instance_type, terraform.workspace)


For local state, Terraform stores the workspace states in a directory called 

terraform.tfstate.d



Count and for each
-------



variable "ami" { 
	default = "ami-061..."
}

variable "instance_type" { 
	default = "m5.large"
}

variable "webserver" {
	type = set
	default = ["web1","web2","web3"]
}

main.tf :

resource "aws_instance" "web" {
	ami 	= var.ami
	instance_type = var.instance_type
	for_each = var.webservers
	tags = { 
		Name = each.value
	}
}



