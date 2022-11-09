# not by instance template, (or maybe by it), but certainly not a MIG but a standalone instance with only 22 port open
resource "google_compute_address" "static_external" {
  name = "ipv4-address"
  address_type = "EXTERNAL"
}

data "local_file" "input_public" {
  filename = local_file.public_ssh_key.filename
}

data "local_sensitive_file" "input_private" {
  filename = local_sensitive_file.private_ssh_key.filename
}

resource "google_compute_instance" "default" {
  depends_on = [local_file.public_ssh_key]

  name         = "internal-access-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["admin", "jenkins-vm", "ansible-vm", "allow-ssh"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.input_public.content}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "debian_boot"
      }
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.terr_sub_vpc_1.id
    access_config {
    nat_ip = google_compute_address.static_external.address
    network_tier = "PREMIUM"
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email = google_service_account.custom_service_account_1.email
    scopes = ["cloud-platform"]
  }
  provisioner "remote-exec" {
    inline = ["echo 'Waiting until SSH is really ready'"]

    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = data.local_sensitive_file.input_private.content
      host = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}, --private-key ${local_sensitive_file.private_ssh_key.filename} ../${var.ansible_folder_name}/playbook-for-jenkins.yaml"
  }
}