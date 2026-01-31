
install-terraform:
	wget https://releases.hashicorp.com/terraform/1.14.2/terraform_1.14.2_linux_amd64.zip
	unzip terraform_1.14.2_linux_amd64.zip && rm terraform_1.14.2_linux_amd64.zip && rm LICENSE.txt
	sudo mv terraform /usr/local/bin/terraform && sudo chown root:root /usr/local/bin/terraform

dev-vm:
	terraform apply -target module.dev_vm.proxmox_virtual_environment_vm.ubuntu_dev_vm \
	-target module.dev_vm.null_resource.ansible_provision_dev_vm


destroy-dev-vm:
	terraform destroy -target module.dev_vm.proxmox_virtual_environment_vm.ubuntu_dev_vm \
	-target module.dev_vm.proxmox_virtual_environment_file.user_data_cloud_init_config \
	-target module.dev_vm.null_resource.ansible_provision_dev_vm

dns-server:
	terraform apply -target module.dns.proxmox_virtual_environment_container.adguard_container

destroy-dns-server:
	terraform destroy -target module.dns.proxmox_virtual_environment_container.adguard_container

omv:
	terraform apply -target module.omv.proxmox_virtual_environment_vm.omv_vm \
	-target module.omv.null_resource.ansible_provision_omv

destroy-omv:
	terraform destroy -target module.omv.proxmox_virtual_environment_vm.omv_vm \
	-target module.omv.proxmox_virtual_environment_file.user_data_cloud_init_config \
	-target module.omv.null_resource.ansible_provision_omv

init:
	ln -sf ./git_hooks/pre-commit .git/hooks/pre-commit
	terraform init
	terraform get

plan:
	terraform plan

apply:
	terraform apply -auto-approve



