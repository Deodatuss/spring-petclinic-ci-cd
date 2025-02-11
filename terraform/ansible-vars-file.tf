# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_file_new" {
  content = <<-DOC
    # Ansible vars_file containing variable values from Terraform.
    # Generated by Terraform local_file resource.

    tf_gcp_project: "${var.gcp_project}"
    tf_region: "${var.region}"
    tf_zone: "${var.zone}"
    tf_cred_file: "${var.cred_file}"

    tf_control_instance_internal_ip: "${google_compute_instance.default.network_interface.0.network_ip}"
    
    
    DOC
  filename = "../ansible/tf_ansible_vars_file.yaml"
}