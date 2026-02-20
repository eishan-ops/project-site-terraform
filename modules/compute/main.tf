


resource "aws_instance" "main" {
  for_each                    = { for vm in var.vms : vm.name => vm }
  ami                         = "ami-0c0a551d0459e9d39" # us-west-2
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  ebs_block_device {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    iops                  = "3000"
    throughput            = "125"
    volume_size           = "8"
    volume_type           = "gp3"

  }
  key_name               = aws_key_pair.logger.key_name
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [each.value.security_group_id]



}

resource "aws_key_pair" "logger" {
  key_name   = "logger"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOsQM+VqXjap1nHQszpeTbeykyFH3fWedyAB2u27NM3iQEsgm2ot9tzzdhouaPbctmCba1TU/4K0CKl+4US7hfYp3aMdu3wMHE1N8K8O3/3vIZ5ZijNDH8my5ocm8DVMyxVdRV0tn+z63NPPGEa4A7irJiWwlcOPIpwIF620/CctmyubOUQYUq8AMerxWTWmQugfUXcO8ezvYDMgsCATXD4fnwHOk33B+8TcB2ie20l5pW7kVegv3WP/WzHVe5C7ocHNegICMdI8Vn32DUPwX86JD6dNAfsNuO9y6a4rp96MxepgrZG62b3td5GKvdUNydeDGTnczVSqQ97rGAS8yB logger"
}
