output "consul-server_name" { value = "${aws_iam_instance_profile.consul-server.name}" }
output "consul_ips" { value = "${aws_instance.consul.*.private_ip})}" }
