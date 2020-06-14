
provider "aws"{
	region="ap-south-1"
	profile="iamuser1profile"
}

resource "aws_security_group" "customsg" {
  name        = "customsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-856e72ed"

ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "TLS from VPC"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name="oskey"
  security_groups=["${aws_security_group.customsg.name}"]

	connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("C:/Users/ajay/Downloads/oskey.pem")
        host = aws_instance.web.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum install httpd  php git -y",
            "sudo systemctl restart httpd",
            "sudo systemctl enable httpd",
        ]
    }



  tags = {
    Name = "tfos"
  }
}
resource "aws_ebs_volume" "MyVol1" {
  availability_zone = "${aws_instance.web.availability_zone}"
  size = 1
  tags = {
    Name = "MyVolume"
  }
}


resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.AttachVol,
]

connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:/Users/ajay/Downloads/oskey.pem")
    host = aws_instance.web.public_ip
}
provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/AjayVenkat13/rep.git /var/www/html/"
    ]
  }
}

resource "aws_volume_attachment" "AttachVol" {
   device_name = "/dev/sdh"
   volume_id   =  "${aws_ebs_volume.MyVol1.id}"
   instance_id = "${aws_instance.web.id}"
   depends_on = [
       aws_ebs_volume.MyVol1,
       aws_instance.web
   ]
 }





