
# INPUTS
variable "ami" {
  type = string
  default = "ami-08f3d892de259504d" # Amazon Linux 2.0 - ami-08f3d892de259504d
  // Ubuntu 18.04 x86 - ami-085925f297f89fce1
}

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

variable "ngrokport" {
  type = number
  default = 4040
  description = "The ngrok service port."
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

# setting to blank will skip creating host DNS record
variable "domain" {
  type = string
  default = "000eyes.dev"
}

variable "docker-run" {
  type    = string
  default = "docker run -p 8080:8080 -p 4040:4040 --name shapeshifter -d 000eyes/shapeshifter deploy notunnel"
}


data "template_file" "init" {
  template = file("${path.module}/init.sh")
  vars = {
      DOCKER_RUN="${var.docker-run}",
      # HTTPSPORT="${var.httpsport}",
      # HTTPPORT="${var.httpport}"
    }
}

data "template_cloudinit_config" "cloud-init" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.init.rendered
  }
}

# data "aws_acm_certificate" "teyes-dev-cert" {
#   domain   = "*.000eyes.dev"
#   statuses = ["ISSUED"]
# }

# resource "aws_acm_certificate" "teyes-cert" {
#   id = "${data.teyes-dev-cert.arn}"
# }

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private-keyfile" {
    content     = tls_private_key.ssh-key.private_key_pem
    filename = "${path.module}/${var.privatekey}"
    file_permission = 0400
}

resource "local_file" "public-keyfile" {
    content     = tls_private_key.ssh-key.public_key_openssh
    filename = "${path.module}/${var.publickey}"
    file_permission = 0644
}

resource "aws_key_pair" "shapeshifter-key" {
  key_name   = "shapeshifter-key"
  public_key = tls_private_key.ssh-key.public_key_openssh
}

resource "aws_instance" "shapeshifter" {
  tags = {
    Name = "shapeshifter"
  }

  key_name = aws_key_pair.shapeshifter-key.key_name

  instance_type = "t2.micro"
  ami = var.ami # Stock AWS Linux
  vpc_security_group_ids = [aws_security_group.shapeshifter-sg.id]
  user_data = data.template_cloudinit_config.cloud-init.rendered

  connection {
    type = "ssh"
    user = var.user
    private_key = tls_private_key.ssh-key.private_key_pem
    agent       = "true"
    host        = self.public_ip
  }
}

resource "aws_security_group" "shapeshifter-sg" {
  name = "shapeshifter-sg"

  ingress {
    from_port   = var.httpsport
    to_port     = var.httpsport
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.httpport
    to_port     = var.httpport
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Open HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open NGROK
  ingress {
    from_port   = var.ngrokport
    to_port     = var.ngrokport
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow pings
  ingress {
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# OUTPUTS

output "publicip" {
  value = "${aws_instance.shapeshifter.public_ip}"
}

output "public_url" {
  value = "https://${aws_instance.shapeshifter.public_ip}:${var.httpsport}"
}

output "keypair" {
  value = "${local_file.private-keyfile.filename}"
}

output "keypairname" {
  value = "${var.privatekey}"
}

output "user" {
  value = "${var.user}"
}



