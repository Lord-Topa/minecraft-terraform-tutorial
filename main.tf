provider "aws" {
  region = "us-west-2"  # Replace with your desired region
}

data "aws_security_group" "existing" {
  filter {
    name   = "group-name"
    values = ["mc-security-group"]  # Replace with your actual security group name
  }
}

data "aws_key_pair" "existing" {
  key_name = "mc-server-key"  # Replace with your actual key pair name
}

resource "aws_instance" "minecraft_server" {
  ami           = "ami-05a6dba9ac2da60cb"  # Amazon Linux 2 AMI (64-bit x86)
  instance_type = "t4g.small"
  key_name      = data.aws_key_pair.existing.key_name

  vpc_security_group_ids = [data.aws_security_group.existing.id]

  tags = {
    Name = "Minecraft-Server"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.minecraft_server.public_ip} > ip_address.txt"
  }
}

output "instance_public_ip" {
  description = "The public IP of the Minecraft server instance"
  value       = aws_instance.minecraft_server.public_ip
}
