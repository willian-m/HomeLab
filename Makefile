
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

k3s-controller:
	terraform apply -target module.k3s_controller.proxmox_virtual_environment_vm.k3s_controller_vm \
	-target module.k3s_controller.null_resource.ansible_provision_k3s_controller

destroy-k3s-controller:
	terraform destroy -target module.k3s_controller.proxmox_virtual_environment_vm.k3s_controller_vm

k3s-gpu-worker:
	terraform apply -target module.k3s_gpu_worker.proxmox_virtual_environment_vm.k3s_gpu_worker_vm \
	-target module.k3s_gpu_worker.null_resource.ansible_provision_k3s_gpu_worker

destroy-k3s-gpu-worker:
	terraform destroy -target module.k3s_gpu_worker.proxmox_virtual_environment_vm.k3s_gpu_worker_vm

jumpbox:
	terraform apply -target module.jumpbox.null_resource.ansible_inventory_jumpbox \
	 -target module.jumpbox.null_resource.ansible_provision_jumpbox \
	-target module.jumpbox.null_resource.ansible_provision_jumpbox

destroy-jumpbox:
	terraform destroy -target module.jumpbox.null_resource.ansible_provision_jumpbox \
	-target module.jumpbox.proxmox_virtual_environment_container.jumpbox

init:
	ln -sf ./git_hooks/pre-commit .git/hooks/pre-commit
	terraform init
	terraform get

plan:
	terraform plan

apply:
	terraform apply -auto-approve


#-------------------------------------------------------------------------------
# Requires an working k8s cluster (e.g, deploy at least k3s-controller above)
# ------------------------------------------------------------------------------

# Necessary to generate secrets
install-sealed-secrets:
	kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.36.0/controller.yaml
	curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.36.0/kubeseal-0.36.0-linux-amd64.tar.gz"
	tar -xvzf kubeseal-0.36.0-linux-amd64.tar.gz kubeseal
	sudo install -m 755 kubeseal /usr/local/bin/kubeseal
	rm kubeseal*