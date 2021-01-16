output "nomad_ips" { value = aws_instance.nomad.*.private_ip }
