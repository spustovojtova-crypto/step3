
# ---- Key pair ----
resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# ---- EC2 instances ----

locals {
  master_user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt upgrade -y

   sudo apt install -y software-properties-common wget curl lsb-release
   sudo add-apt-repository -y ppa:deadsnakes/ppa
   sudo apt update -y

    # Створюємо робочу папку для Ansible
    mkdir -p /home/ubuntu/ansible
    chown ubuntu:ubuntu /home/ubuntu/ansible

    # Забезпечуємо існування користувача ubuntu і authorized_keys
    mkdir -p /home/ubuntu/.ssh
    echo "${file(var.public_key_path)}" > /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/authorized_keys
  EOF

  worker_user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt upgrade -y

    # Створюємо робочу папку для Ansible
    mkdir -p /home/ubuntu/ansible
    chown ubuntu:ubuntu /home/ubuntu/ansible

    # Забезпечуємо існування користувача ubuntu і authorized_keys
    mkdir -p /home/ubuntu/.ssh
    echo "${file(var.public_key_path)}" > /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/authorized_keys
  EOF
}


resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.ubuntu_ami.id
  instance_type               = var.instance_type_master
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.key.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  user_data                   = local.master_user_data
  tags                        = { Name = "jenkins-master" }
}

resource "aws_instance" "jenkins_worker" {
  ami                         = data.aws_ami.ubuntu_ami.id
  instance_type               = var.instance_type_worker
  subnet_id                   = aws_subnet.private.id
  key_name                    = aws_key_pair.key.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = false
  user_data                   = local.worker_user_data

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  tags = { Name = "jenkins-worker" }
}

# Generate inventory file
data "template_file" "inventory" {
  template = <<EOT
[jenkins_master]
${aws_instance.jenkins_master.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path}

[jenkins_worker]
${aws_instance.jenkins_worker.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path}
EOT
}


resource "local_file" "inventory_file" {
  content  = data.template_file.inventory.rendered
  filename = "${path.module}/../ansible/inventory.ini"
}

