variable "default-region" {}
variable "aws-profile" {}
variable "controller-name" {}
variable "node-basename" {}
variable "controller-instance-type" {}
variable "node-instance-type" {}
variable "node-instance-count" {}
variable "base-image-ami" {}
variable "cluster-node-names" {
  type = map(any)
}
