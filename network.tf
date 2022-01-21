# VCN1
resource "oci_core_virtual_network" "FoggyKitchenVCN1" {
  provider       = oci.requestor
  cidr_block     = var.VCN1-CIDR
  dns_label      = "FKVCN1"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenVCN1"
}

# VCN2
resource "oci_core_virtual_network" "FoggyKitchenVCN2" {
  provider       = oci.acceptor
  cidr_block     = var.VCN2-CIDR
  dns_label      = "FKVCN2"
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  display_name   = "FoggyKitchenVCN2"
}


# DHCP Options for VCN1
resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
  provider       = oci.requestor
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN1.id
  display_name   = "FoggyKitchenDHCPOptions1"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["foggykitchen.com"]
  }
}

# DHCP Options for VCN2
resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions2" {
  provider       = oci.acceptor
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN2.id
  display_name   = "FoggyKitchenDHCPOptions1"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["foggykitchen.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway1" {
  provider       = oci.requestor
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenInternetGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN1.id
}

# Route Table for IGW and DRG1
resource "oci_core_route_table" "FoggyKitchenRouteTableVCN1" {
  provider       = oci.requestor
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN1.id
  display_name   = "FoggyKitchenRouteTableVCN2"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway1.id
  }

  route_rules {
    destination       = var.VCN2-CIDR
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.FoggyKitchenDRG1.id
  }
}

# Internet Gateway2
resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway2" {
  provider       = oci.acceptor
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenInternetGateway2"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN2.id
}

# Route Table for VCN2
resource "oci_core_route_table" "FoggyKitchenRouteTableVCN2" {
  provider       = oci.acceptor
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN2.id
  display_name   = "FoggyKitchenRouteTableVCN2"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway2.id
  }

  route_rules {
    destination       = var.VCN1-CIDR
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.FoggyKitchenDRG2.id
  }
}


# Security List for SSH/HTTP/HTTPS in VCN1
resource "oci_core_security_list" "FoggyKitchenWebSecurityList1" {
  provider       = oci.requestor
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenWebSecurityList1"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN1.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.ssh_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN1-CIDR
  }
}

# Security List for SSH/HTTP/HTTPS in VCN2
resource "oci_core_security_list" "FoggyKitchenWebSecurityList2" {
  provider       = oci.acceptor
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  display_name   = "FoggyKitchenWebSecurityList2"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN2.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.ssh_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }
  
  ingress_security_rules {
    protocol = "6"
    source   = var.VCN2-CIDR
  }

}

# WebSubnet in VCN1
resource "oci_core_subnet" "FoggyKitchenWebSubnet" {
  provider          = oci.requestor
  cidr_block        = var.WebSubnet-CIDR
  display_name      = "FoggyKitchenWebSubnet"
  dns_label         = "fknweb"
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN1.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableVCN1.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenWebSecurityList1.id]
}

# DRSubnet in VCN2
resource "oci_core_subnet" "FoggyKitchenDRSubnet" {
  provider          = oci.acceptor
  cidr_block        = var.DRSubnet-CIDR
  display_name      = "FoggyKitchenDRSubnet"
  dns_label         = "fkndr"
  compartment_id    = oci_identity_compartment.ExternalCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN2.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableVCN2.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions2.id
  security_list_ids = [oci_core_security_list.FoggyKitchenWebSecurityList2.id]
}

