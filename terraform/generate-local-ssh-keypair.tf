resource "null_resource" "ssh_gen_script" {
  triggers = {
    user_name = var.ssh_user
    keyfile_name = var.ssh_keyfile_name
  }
  provisioner "local-exec" {
    working_dir = "../${var.keyfiles_folder_name}/"
    command = "ssh-keygen -t rsa -f ./temp_${var.ssh_keyfile_name} -C temp_${var.ssh_user} -b 2048 -N \"\" "
  }
}

resource "local_sensitive_file" "private_ssh_key" {
  depends_on = [null_resource.ssh_gen_script]
  filename = "../${var.keyfiles_folder_name}/${var.ssh_keyfile_name}"
  source = "../${var.keyfiles_folder_name}/temp_${var.ssh_keyfile_name}"
}

resource "local_file" "public_ssh_key" {
  depends_on = [local_sensitive_file.private_ssh_key]
  filename = "../${var.keyfiles_folder_name}/${var.ssh_keyfile_name}.pub"
  source = "../${var.keyfiles_folder_name}/temp_${var.ssh_keyfile_name}.pub"
}

resource "null_resource" "ssh_delete_script" {
  depends_on = [local_file.public_ssh_key]
  provisioner "local-exec" {
    working_dir = "../${var.keyfiles_folder_name}/"
    command = "rm temp_${var.ssh_keyfile_name} temp_${var.ssh_keyfile_name}.pub"
    on_failure = continue
  }
  provisioner "local-exec" {
    working_dir = "../${var.keyfiles_folder_name}/"
    command = "del temp_${var.ssh_keyfile_name} temp_${var.ssh_keyfile_name}.pub"
    on_failure = continue
  }
}