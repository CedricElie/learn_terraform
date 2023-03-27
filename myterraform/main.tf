terraform {
	required_providers {
	local = {
		source = "hashicorp/local"
	        }
					   }
}

resource "local_file" "pet" {
    filename = "/Users/mac/Desktop/KodeKloud/Terraform/myterraform/pets.txt"
    content = "We love pets !"
}

resource "random_pet" "my-pet" {
	prefix = "Mrs"
	length = "1"
}

resource "random_string" "server-suffix" {
	length = 6
	upper = false
	special = false
}

resource "local_file" "web" {
	filename = "/Users/mac/Desktop/KodeKloud/Terraform/myterraform/jango.txt"
	content =  "jungle fever"
	for_each = var.webservers
	tags = { 
		Name = each.value
	}
}