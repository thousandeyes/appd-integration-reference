
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

data "aws_route53_zone" "zone" {
  name = "${var.domain}."
}

resource "aws_route53_record" "cname" {
  count = length(var.hostname) > 0 ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.hostname}.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${var.ip}"]
}


output "hostname" {
  value = "${var.hostname}"
}


output "domain" {
  value = "${var.domain}"
}