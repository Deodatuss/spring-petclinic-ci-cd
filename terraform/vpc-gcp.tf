### VPC ###
resource "google_compute_network"  "terr_vpc_1" {
  depends_on = [google_project_service.api_7_cloudsql_admin]

    name = "terr-vpc-1"
    auto_create_subnetworks = false
    enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "terr_sub_vpc_1" {
  name = "terr-sub-vpc-1"
  ip_cidr_range = var.ip_cidr_range
  network = google_compute_network.terr_vpc_1.id

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.secondary_ip_service_cidr_range
  }
  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = var.secondary_ip_pod_cidr_range
  }


  private_ip_google_access = true
}
### VPC ###

### Firewall that allows ping and ssh connection to VM public ip ###
resource "google_compute_firewall" "allow_ssh_http_for_vm" {
  name    = "allow-ssh-http-for-vm"
  network = google_compute_network.terr_vpc_1.name
  priority = 10
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
}