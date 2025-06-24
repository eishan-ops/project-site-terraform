resource "aws_instance" "foo" {
  ami           = "ami-0c0a551d0459e9d39" # us-west-2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "default"
    delete_on_termination = true
    iops = "3000"
    throughput = "125"
    volume_size = "8"
    volume_type = "gp3"

  }
  key_name = aws_key_pair.logger.key_name
  # vpc_security_group_ids = [  ]
  # subnet_id = 
  

}

resource "aws_key_pair" "logger" {
  key_name = "project-site-logger"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTRREzdq/axPbJsK7n1vvjk+HyWLVkqROol0hhsaSAQmVvg/eu06Z4RJeLStLOrzGsn/XifaTmWzg1HrtJljGkW84rsEtWhwHwW+9jg62j/0oDbJoOw3ruVTns3XbEjC/nFr8vuIMWdvuNDqThABx/It2na8Hx5cT1nKY0mKA1B1L8IzCDlvFvaYUExl5G92Lu2EsqxaVwb7J3Q98QzX4/IeTbNuwA8dg9na2z4FRfQlNX9xzPH+tuImYIk4nss6sATmsAsWi2HLmvn4GlH1NOFezr5cbiOL+wihGJ+gVn3CNXyJLfUVkpJcoOqLGfppU/bT9Cw+vqYSOsb6KAI7cH project-site-logger"
}
