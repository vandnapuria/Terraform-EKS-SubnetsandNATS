# getting the subnet-id in the output

output "EKS1" {
  value = "${aws_subnet.EKS1.id}"
}

output "EKS2" {
  value = "${aws_subnet.EKS2.id}"
}


output "EKS3" {
  value = "${aws_subnet.EKS3.id}"
}
