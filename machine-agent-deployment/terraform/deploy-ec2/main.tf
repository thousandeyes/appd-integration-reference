
terraform {
  backend "local" {
    path = "/shapeshifter/aws.tfstate"
  }
}

locals {
  owner = "hashlock@thousandeyes.com"
}


# INPUTS
variable "httpsport" {
  type = number
  default = 8080
  description = "The external port to be used by Shapeshifter."
}

variable "httpport" {
  type = number
  default = 8000
  description = "The external port to be used by Shapeshifter."
}

variable "workingdir" {
  type    = string
  default = "/opt/shapeshifter"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "publickey" {
  type = string
  default = "shapeshifter-key.pub"
}

variable "privatekey" {
  type = string
  default = "shapeshifter-key"
}

variable "user" {
  type = string
  default = "ec2-user"
}

variable "hostname" {
  type = string
  default = "shapeshifter"
}

variable "docker-run" {
  type    = string
  default = "docker run -p 8080:8080 -p 4040:4040 --name shapeshifter -d 000eyes/shapeshifter deploy local --notunnel"
}

provider "aws" {
  alias = "user"
  region = var.region
  shared_credentials_file = "/root/.aws/credentials"
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

module "ec2" {
  source = "./../modules/ec2"
  providers = {
    aws = aws.user
  }
  httpsport = var.httpsport
  docker-run = var.docker-run
}

# module "aname" {
#   source = "./../modules/route53/aname"
#   providers = {
#     aws = aws.teyes
#   }
#   hostname = var.hostname
#   ip = module.ec2.publicip
# }

# OUTPUTS

output "publicip" {
  value = "${module.ec2.publicip}"
}

output "public_url" {
  value = "${module.ec2.public_url}"
}

output "public_url_domain" {
  value = length(var.hostname) > 0 ? "https://${var.hostname}.000eyes.dev:${var.httpsport}" : ""
}

output "keypair" {
  value = "${module.ec2.keypair}"
}

output "keypairname" {
  value = "${module.ec2.keypairname}"
}

output "user" {
  value = "${module.ec2.user}"
}

