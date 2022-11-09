#!/usr/bin/env #!/usr/bin/env bash
source ./terraform.tfvars
ssh-keygen -t rsa -f ../$keyfiles_folder_name_or_relative_path/$ssh_keyfile_name -C $ssh_user -b 2048 -N ""
