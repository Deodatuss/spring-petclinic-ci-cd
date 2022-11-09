# not by instance template, (or maybe by it), but certainly not a MIG but a standalone instance with only 22 port open
resource "google_compute_address" "static_external" {
  name = "ipv4-address"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "default" {
  depends_on = [local_file.public_ssh_key]

  name         = "internal-access-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["admin", "jenkins-vm", "ansible-vm", "allow-ssh"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(local_file.public_ssh_key.filename)}"
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
}