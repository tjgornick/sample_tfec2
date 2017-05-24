provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-west-2"
}

resource "aws_security_group" "sample_http_ssh" {
  name = "sample_http_ssh"
  description = "allow http, ssh traffic in, all out"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sample" {
  ami = "ami-efd0428f"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  availability_zone = "us-west-2a"
  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 1
    volume_type = "gp2"
  }
  security_groups = ["sample_http_ssh"]
  connection {
        user = "${var.ssh_user}"
        private_key = "${file("${var.key_path}")}"
  }
  provisioner "file" {
    source = "files/sample"
    destination = "/tmp/sample"
  }
  provisioner "file" {
    source = "files/index.html"
    destination = "/tmp/index.html"
  }
  provisioner "remote-exec" {
    script = "files/provision.sh"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.sample.id}"
}

output "sample_public_dns" {
  value = "${aws_instance.sample.public_dns}"
}

