output "consul-server_name" { value = aws_iam_instance_profile.consul.name }
output "consul_ips" { value = aws_instance.consul.*.private_ip }
