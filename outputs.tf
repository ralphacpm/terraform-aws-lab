#Output the Public IP so we don't have to look for it
output "server_public_ip" {
  value = aws_instance.my_server.public_ip
}