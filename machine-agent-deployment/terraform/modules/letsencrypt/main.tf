variable "fqdn" {
  type = string
  default = "sh.000eyes.dev"
}

variable "email" {
  type = string
  default = "acmehero@thousandeyes.com"
}

variable "aws_access_key" {
  type = string
  default = ""
}

variable "aws_secret_key" {
  type = string
  default = ""
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory" #"https://acme.api.letsencrypt.org/directory" #https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA" # 
}


resource "tls_private_key" "certificate" {
  algorithm = "RSA" # 
}


resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.email
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.fqdn

  dns_challenge {
    provider = "route53"
    config = {
      AWS_ACCESS_KEY_ID     = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION    = "us-east-1"
    }
  }
}

data "template_file" "fullchain" {
  template = "$${certificate}$${private_key}$${ca_certificate}"

  vars = {
    certificate    = acme_certificate.certificate.certificate_pem
    private_key    = tls_private_key.certificate.private_key_pem
    ca_certificate = acme_certificate.certificate.issuer_pem
  }
}


resource "local_file" "cert-private-keyfile" {
    content     = acme_certificate.certificate.private_key_pem
    filename = "${path.module}/server.key"
    file_permission = 0400
}

resource "local_file" "cert-certfile" {
    content     = data.template_file.fullchain.rendered #acme_certificate.certificate.certificate_pem
    filename = "${path.module}/server.cert"
    file_permission = 0644
}


output "certpath" {
  value = "${path.module}/server.cert"
} 


output "certkeypath" {
  value = "${path.module}/server.key"
} 