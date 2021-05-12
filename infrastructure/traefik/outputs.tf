output "traefik_public_ips" { value = aws_instance.traefik.*.public_ip }
