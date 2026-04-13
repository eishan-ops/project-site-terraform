


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

  tags = {
    Name = each.key
    Tier = each.value.tier
  }

  key_name               = aws_key_pair.logger.key_name
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [each.value.security_group_id]



}

resource "aws_key_pair" "logger" {
  key_name   = "logger"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCch4LWGFEyzmecfbcWisviMysfVtU6RucmfJORkOlF9S3e6oPU1jLUQTtbXnaczFwWVAVZXvIpfPorRT3TYPH0TwdM6vtQxNy+lPo7dxzaKxM84rJg6TmgAHMcrgR2uaIhYd4XVtIu7Z52BTGxco1RRzcU334VwQBKzKw3ad4fMefVVeu5a2xADlUPyvNdTqVdvPxGkNvwrnMll87+BkF1cgG3fGa2QrOXU0BwQPVAWES2EpOzk7hTrOENUHyySKPHtixmRLxxfPm/cJfoXtqaT+2RbeN76pVonG9QdBJO0i4YvjmyXu6Ajav11864EMto2DoxHeNw8BA5Q7RCWx0j logger"
}
