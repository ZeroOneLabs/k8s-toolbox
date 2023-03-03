
output "ami-id" {
  value = data.aws_ami.ubuntu-20-lts.id
}

output "default-vpc-id" {
  value = data.aws_vpc.default-vpc.id
}


/* output "kontroller-ips" {
  value = { for node in keys(aws_instance.k8s-nodes) : node => aws_instance.k8s-nodes[node].public_ip }
} */
