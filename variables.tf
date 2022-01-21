variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "availablity_domain_name" {
  default = ""
}

variable "availablity_domain_name2" {
  default = ""
}

variable "region1" {
  default = "eu-frankfurt-1"
}

variable "region2" {
  default = "eu-amsterdam-1"
}

variable "VCN1-CIDR" {
  default = "10.0.0.0/16"
}

variable "VCN2-CIDR" {
  default = "192.168.0.0/16"
}

variable "WebSubnet-CIDR" {
  default = "10.0.1.0/24"
}

variable "DRSubnet-CIDR" {
  default = "192.168.1.0/24"
}


variable "Shape" {
  default = "VM.Standard.E3.Flex"
}

variable "FlexShapeOCPUS" {
  default = 1
}

variable "FlexShapeMemory" {
  default = 1
}

variable "instance_os" {
  default = "Oracle Linux"
}

variable "linux_os_version" {
  default = "7.9"
}

variable "webservice_ports" {
  default = ["80", "443"]
}

variable "ssh_ports" {
  default = ["22"]
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]
}


# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_shape    = contains(local.compute_flexible_shapes, var.Shape)
}
