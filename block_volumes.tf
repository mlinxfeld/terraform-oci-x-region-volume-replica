# 100 GB Block Volume
resource "oci_core_volume" "FoggyKitchenWebServer1BlockVolume100G" {
  provider            = oci.requestor
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.R-ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebServer1 BlockVolume 100G"
  size_in_gbs         = "100"
  
  block_volume_replicas { 
    availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.A-ADs.availability_domains[0], "name") : var.availablity_domain_name2
    display_name = "FoggyKitchenWebServer1 BlockVolume 100G replica"
  }  
  block_volume_replicas_deletion = true
}

# Attachment of 100 GB Block Volume to Webserver1
resource "oci_core_volume_attachment" "FoggyKitchenWebServer1BlockVolume100G_attach" {
  provider        = oci.requestor
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.FoggyKitchenWebServer1.id
  volume_id       = oci_core_volume.FoggyKitchenWebServer1BlockVolume100G.id
}


# 100 GB Block Volume from replica
resource "oci_core_volume" "FoggyKitchenWebServer2BlockVolume100G" {
  depends_on          = [oci_core_volume.FoggyKitchenWebServer1BlockVolume100G, 
                         null_resource.FoggyKitchenWebServer1HTTPD,
                         null_resource.FoggyKitchenWebServer1_oci_httpd_data_fstab]
  provider            = oci.acceptor
  availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.A-ADs.availability_domains[0], "name") : var.availablity_domain_name2
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebServer2 BlockVolume 100G"
  size_in_gbs         = "100"
  source_details {
    id   = lookup(data.oci_core_block_volume_replicas.FoggyKitchenWebServer1BlockVolume100G_xregion_replica.block_volume_replicas[0], "id")
    type = "blockVolumeReplica"
  }
}


# Attachment of 100 GB Block Volume to Webserver2
resource "oci_core_volume_attachment" "FoggyKitchenWebServer2BlockVolume100G_attach" {
  provider        = oci.acceptor
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.FoggyKitchenWebServer2.id
  volume_id       = oci_core_volume.FoggyKitchenWebServer2BlockVolume100G.id
}
