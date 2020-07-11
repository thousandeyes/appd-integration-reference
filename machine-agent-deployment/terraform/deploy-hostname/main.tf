
terraform {
  backend "local" {
    path = "/shapeshifter/hostname.tfstate"
  }
}

variable "hostname" {
  type = string
  default = ""
}

variable "ip" {
  type = string
  default = ""
}

# setting to blank will skip creating host DNS record
variable "domain" {
  type = string
  default = "000eyes.dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_access_key" {
  type = string
  default = ""
}

variable "aws_secret_key" {
  type = string
  default = ""
}

provider "aws" {
  alias = "teyes"
  region = var.region
  
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}


module "aname" {
  source = "./../modules/route53/aname"
  providers = {
    aws = aws.teyes
  }

  hostname = var.hostname
  ip = var.ip
}

output "hostname" {
  value = "${var.hostname}"
}

