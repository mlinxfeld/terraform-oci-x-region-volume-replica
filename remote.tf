# Attachment of block volume to Webserver1

resource "null_resource" "FoggyKitchenWebServer1_oci_iscsi_attach" {
  depends_on = [oci_core_volume_attachment.FoggyKitchenWebServer1BlockVolume100G_attach]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebServer1_VNIC1.public_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
    }
    inline = ["sudo /bin/su -c \"rm -Rf /home/opc/iscsiattach.sh\""]
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebServer1_VNIC1.public_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
    }
    source      = "iscsiattach.sh"
    destination = "/home/opc/iscsiattach.sh"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebServer1_VNIC1.public_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
    }
    inline = ["sudo /bin/su -c \"chown root /home/opc/iscsiattach.sh\"",
      "sudo /bin/su -c \"chmod u+x /home/opc/iscsiattach.sh\"",
    "sudo /bin/su -c \"/home/opc/iscsiattach.sh\""]
  }

}

# Mount of attached block volume on Webserver1

resource "null_resource" "FoggyKitchenWebServer1_oci_httpd_data_fstab" {
  depends_on = [null_resource.FoggyKitchenWebServer1_oci_iscsi_attach]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebServer1_VNIC1.public_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
    }
    inline = ["echo '== Start of null_resource.FoggyKitchenWebserver1_oci_httpd_data_fstab'",
      "sudo -u root parted /dev/sdb --script -- mklabel gpt",
      "sudo -u root parted /dev/sdb --script -- mkpart primary ext4 0% 100%",
      "sudo -u root mkfs.ext4 /dev/sdb1",
      "sudo -u root mkdir /httpd_data",
      "sudo -u root mount /dev/sdb1 /httpd_data",
      "sudo /bin/su -c \"echo '/dev/sdb1              /httpd_data  ext4    defaults,noatime,_netdev    0   0' >> /etc/fstab\"",
      "sudo -u root mount | grep sdb1",
      "echo '== End of null_resource.FoggyKitchenWebserver1_oci_httpd_data_fstab'",
    ]
  }

}

# Software installation within WebServer1 Instance

resource "null_resource" "FoggyKitchenWebServer1HTTPD" {
  depends_on = [oci_core_instance.FoggyKitchenWebServer1,null_resource.FoggyKitchenWebServer1_oci_httpd_data_fstab]
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebServer1_VNIC1.public_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
    }
    inline = ["echo '== 1. Installing HTTPD package with yum'",
      "sudo -u root yum -y -q install httpd",

      "echo '== 2. Creating /httpd_data/index.html'",
      "sudo -u root touch /httpd_data/index.html",
      "sudo /bin/su -c \"echo 'Welcome to FoggyKitchen.com! These are both WEBSERVERS under LB umbrella with shared index.html ...' > /httpd_data/index.html\"",

      "echo '== 3. Adding Alias and Directory /httpd_data to /etc/httpd/conf/httpd.conf'",
      "sudo /bin/su -c \"echo 'Alias /httpd_data/ /httpd_data/' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '<Directory /httpd_data>' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'AllowOverride All' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'Require all granted' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '</Directory>' >> /etc/httpd/conf/httpd.conf\"",

      "echo '== 3. Disabling SELinux'",
      "sudo -u root setenforce 0",

      "echo '== 4. Disabling firewall and starting HTTPD service'",
      "sudo -u root service firewalld stop",
    "sudo -u root service httpd start"]
  }
}


