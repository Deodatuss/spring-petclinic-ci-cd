variable "keyfiles_folder_name_or_relative_path" {
    type        = string
    # default     = "keys"
    description = "simple folder name if at the same level as terraform folder, or path in format folder1/folder2 if higher"
}
variable "ssh_user" {
    type        = string
    # default     = "ansible"
}
variable "ssh_keyfile_name" {
    type        = string
    # default     = "ansible_rsa_v3"
}


variable "ansible_folder_name" {
    type        = string
    default     = "ansible"
}
variable "cred_file" {
    type        = string
    default     = "../keys/kuber-terr-cicd-a90c610d0b13.json"
}


variable "gcp_project" {
    type        = string
    default     = "kuber-terr-cicd"
}
variable "region" {
    type        = string
    default     = "us-central1"
}
variable "zone" {
    type        = string
    default     = "us-central1-c"
}
variable "ip_cidr_range" {
    type        = string
    default     = "10.10.0.0/16"
}
variable "secondary_ip_service_cidr_range" {
    type        = string
    default     = "192.168.10.0/24"
}
variable "secondary_ip_pod_cidr_range" {
    type        = string
    default     = "192.168.64.0/24"
}
