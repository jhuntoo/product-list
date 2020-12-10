variable "gcp_project" {}
variable "region" { type = string}
variable "stack_prefix" { type = string }
variable "nodepool_count" { type = number}
variable "machine_type" { type = string}
variable "initial_node_count" {type = number}
variable "preemptible" {type = bool }
variable "master_version" {
  description = "The version of GKE to install on the master nodes"
}
variable "nodepool_version" {
  description = "The version of GKE to install on the nodepool nodes"
}