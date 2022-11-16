# not by instance template, (or maybe by it), but certainly not a MIG but a standalone instance with only 22 port open
locals {
  public_ssh_key_path = "../${var.keyfiles_folder_name_or_relative_path}/${var.ssh_keyfile_name}.pub"
  private_ssh_key_path = "../${var.keyfiles_folder_name_or_relative_path}/${var.ssh_keyfile_name}"
}

resource "google_compute_address" "static_external" {
  name = "ipv4-address"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "default" {
  name         = "internal-access-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["admin", "jenkins-vm", "ansible-vm", "allow-ssh", "allow-jenkins"]

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(local.public_ssh_key_path)}"
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
    # nat_ip = google_compute_address.static_external.address
    # network_tier = "PREMIUM"
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
     private_key = file(local.private_ssh_key_path)
     host = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
   }
 }
  provisioner "local-exec" {
    command = join(" ", ["ANSIBLE_CONFIG='../${var.ansible_folder_name}/ansible.cfg'",
    "ansible-playbook",
    "-i ${google_compute_instance.default.network_interface.0.access_config.0.nat_ip},",
    "--private-key ${local.private_ssh_key_path}",
    "../${var.ansible_folder_name}/playbook-for-jenkins.yaml"])
  }
}
