terraform {
  backend "local" {
    path = "/shapeshifter/cert.tfstate"
  }
}

variable "hostname" {
  type = string
  default = ""
}

variable "domain" {
  type = string
  default = "000eyes.dev"
}
variable "aws_access_key" {
  type = string
  default = ""
}

variable "aws_secret_key" {
  type = string
  default = ""
}

module "cert" {
  source = "./../modules/letsencrypt"
  fqdn = "${var.hostname}.${var.domain}"
  email = "acmehero@thosuandeyes.com"

  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

}

output "certpath" {
  value = "${module.cert.certpath}"
} 

output "certkeypath" {
  value = "${module.cert.certkeypath}"
} 