Terraform_Challenge_2

1. Install terraform 1.1.5

wget https://releases.hashicorp.com/terraform/1.1.5/terraform_1.1.5_linux_amd64.zip
unzip terraform_1.1.5_linux_amd64.zip
mv terraform /usr/local/bin
terraform version


2. Check the docker provider


file: provide.tf
----------------

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {}


3. imgaes.tf
---------------

resource "docker_image" "php-httpd-image" {
  name = "php-httpd:challenge"
  build {
    path = "/root/code/terraform-challenges/challenge2/lamp_stack/php_httpd/"
    label = {
      challenge : "second"
    }
  }
}

resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    path = "/root/code/terraform-challenges/challenge2/lamp_stack/custom_db/"
    label = {
      challenge : "second"
    }
  }
}


4. volume.tf
----------------
  
resource "docker_volume" "mariadb_volume" {
  name = "mariadb-volume"
}

5. network.tf
----------------

resource "docker_network" "private_network" {
  name = "my_network"
}


6. container.tf
----------------
  
resource "docker_container" "php-httpd" {
  name     = "webserver"
  image    = docker_image.php-httpd-image.name
  hostname = "php-httpd"
  labels {
    label = "challenge"
    value = "second"
  }
  networks_advanced {
    name = docker_network.private_network.name
  }
  ports {
    internal = 80
    external = 80
    ip       = "0.0.0.0"
  }
  volumes {
    container_path = "/var/www/html"
    host_path      = "/root/code/terraform-challenges/challenge2/lamp_stack/website_content/"
  }
}

resource "docker_container" "mariadb" {
  name  = "db"
  image = docker_image.mariadb-image.name
  hostname = "db"
  labels {
        label = "challenge"
        value = "second"
  }
  networks_advanced {
    name = docker_network.private_network.name
  }
  ports {
    internal = 3306
        external = 3306
        ip = "0.0.0.0"
  }
  env = ["MYSQL_ROOT_PASSWORD=1234","MYSQL_DATABASE=simple-website"]
  volumes {
    container_path = "/var/lib/mysql"
        volume_name = docker_volume.mariadb_volume.name
  }
}

resource "docker_container" "phpmyadmin" {
  name  = "db_dashboard"
  image = "phpmyadmin/phpmyadmin"
  hostname = "phpmyadmin"
  labels {
        label = "challenge"
        value = "second"
  }
  networks_advanced {
    name = docker_network.private_network.name
  }
  ports {
    internal = 80
        external = 8081
        ip = "0.0.0.0"
  }
  depends_on = [ docker_container.mariadb ]
  links = [ docker_container.mariadb.name ]
}
