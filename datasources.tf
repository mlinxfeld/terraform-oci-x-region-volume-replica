# Home Region Subscription DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid
  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# Gets a list of Availability Domains in Acceptor region
data "oci_identity_availability_domains" "A-ADs" {
  provider       = oci.acceptor
  compartment_id = var.tenancy_ocid
}


# Gets a list of Availability Domains in Requestor region
data "oci_identity_availability_domains" "R-ADs" {
  provider       = oci.requestor
  compartment_id = var.tenancy_ocid
}

# Images DataSource in Acceptor region
data "oci_core_images" "A-OSImage" {
  provider                 = oci.acceptor
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.Shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# Images DataSource in Requestor region
data "oci_core_images" "R-OSImage" {
  provider                 = oci.requestor
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.Shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# WebServer1 Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "FoggyKitchenWebServer1_VNIC1_attach" {
  provider            = oci.requestor
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.R-ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  instance_id         = oci_core_instance.FoggyKitchenWebServer1.id
}

# WebServer1 Compute VNIC DataSource
data "oci_core_vnic" "FoggyKitchenWebServer1_VNIC1" {
  provider = oci.requestor
  vnic_id  = data.oci_core_vnic_attachments.FoggyKitchenWebServer1_VNIC1_attach.vnic_attachments.0.vnic_id
}

# WebServer2 Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "FoggyKitchenWebServer2_VNIC1_attach" {
  provider            = oci.acceptor
  availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.A-ADs.availability_domains[0], "name") : var.availablity_domain_name2
  compartment_id      = oci_identity_compartment.ExternalCompartment.id
  instance_id         = oci_core_instance.FoggyKitchenWebServer2.id
}

# WebServer2 Compute VNIC DataSource
data "oci_core_vnic" "FoggyKitchenWebServer2_VNIC1" {
  provider = oci.acceptor
  vnic_id  = data.oci_core_vnic_attachments.FoggyKitchenWebServer2_VNIC1_attach.vnic_attachments.0.vnic_id
}



