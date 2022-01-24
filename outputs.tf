# WebServer1_PublicIP
output "FoggyKitchenWebServer1_PublicIP" {
  value = [data.oci_core_vnic.FoggyKitchenWebServer1_VNIC1.public_ip_address]
}

# WebServer2_PublicIP
output "FoggyKitchenWebServer2_PublicIP" {
  value = [data.oci_core_vnic.FoggyKitchenWebServer2_VNIC1.public_ip_address]
}

# Generated Private Key for WebServer Instances
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}
