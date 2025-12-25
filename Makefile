
install-terraform:
	wget https://releases.hashicorp.com/terraform/1.14.2/terraform_1.14.2_linux_amd64.zip
	unzip terraform_1.14.2_linux_amd64.zip && rm terraform_1.14.2_linux_amd64.zip && rm LICENSE.txt
	sudo mv terraform /usr/local/bin/terraform && sudo chown root:root /usr/local/bin/terraform

destroy-dev-vm:
	terraform destroy -target module.dev_vm.proxmox_virtual_environment_vm.ubuntu_dev_vm -target module.dev_vm.proxmox_virtual_environment_file.user_data_cloud_config

init:
	ln -sf ./git_hooks/pre-commit .git/hooks/pre-commit
	terraform init
	terraform get

plan:
	terraform plan

apply:
	terraform apply -auto-approve



