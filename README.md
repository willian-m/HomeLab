# Home Lab deployment with Terraform and Proxmox

This repository contains Terraform configurations to deploy and manage a home lab environment using Proxmox as the virtualization platform. This setup assumes you have a Proxmox server up and running and accessible via the network.

## Motivation

I had some spare hardware lying around and wanted to experiment with some 
self-hosted services. I've eventually learned learned about proxmox and, once 
I set up one or two services, it quickly became apparent that managing 
everything manually and keeping documentation up to date was going to be a pain.
 Hence, I decided it would be the perfect opportunity to learn Terraform and 
 infra as a code.

Services included will grow over time as my personal needs evolve. Also, I hope 
this to be useful for others looking to set up a similar environment.

## Features

Currently, the setup includes:

- Dev VM for remote development and testing of projects.
- OMV for storage management (NFS share is automatically created on this VM).
- DNS server using AdGuard Home.
- K3s controller for Kubernetes cluster management.

## Prerequisites

- Proxmox VE installed and configured on a server which you have root access.
- Access to a Proxmox API token or user credentials with sufficient permissions.
- SSH key pair for secure access to the VMs.
- `mkpasswd` utility to generate hashed passwords.

## Configuration

1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Edit the `variables.tfvars` file to set your Proxmox server details, VM specifications, and other configurations.
4. Edit the `secrets.auto.tfvars` file to set sensitive information like password and API tokens. Make sure this file is not committed to version control.

## K3s GPU Worker Setup

The setup includes a GPU-enabled worker node for the K3s cluster. This requires specific configuration on the Proxmox host and the K3s controller.

### 1. Enable GPU Passthrough on Proxmox

Before deploying the GPU worker, you must enable IOMMU and PCI passthrough on your Proxmox host.

1.  **Edit GRUB configuration**:
    Open `/etc/default/grub` and add `intel_iommu=on iommu=pt` to `GRUB_CMDLINE_LINUX_DEFAULT`.
    ```bash
    GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
    ```
    Update GRUB: `update-grub`

2.  **Load VFIO Modules**:
    Add the following to `/etc/modules`:
    ```
    vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd
    ```

3.  **Blacklist Drivers & Bind GPU**:
    Create `/etc/modprobe.d/blacklist.conf` to blacklist `nouveau` (or `amdgpu`):
    ```
    blacklist nouveau
    ```
    Identify your GPU PCI IDs using `lspci -nnk` (look for your GPU and its audio controller) and create `/etc/modprobe.d/vfio.conf`:
    ```
    options vfio-pci ids=10de:2520,10de:228e disable_vga=1
    ```
    *(Replace IDs with your specific device IDs)*

    Update initramfs: `update-initramfs -u`

4.  **Get Device IDs**:
    Run `lspci -nn | grep VGA` to find your GPU. The output will look like `01:00.0 ... [10de:2520]`.
    *   `01:00.0` is the `gpu_pci_id`.
    *   `10de:2520` is the `gpu_device_id`.

    Review `lspci -nnk` output for the Subsystem ID:
     *   Look for `Subsystem: ... [1028:0a61]` (Example).
     *   `1028:0a61` is the `gpu_subsystem_id`.

    To find the IOMMU Group, run:
    ```bash
    find /sys/kernel/iommu_groups/ -type l | grep <gpu_pci_id>
    ```
    *   Example output: `/sys/kernel/iommu_groups/16/devices/0000:01:00.0`
    *   `16` is the `gpu_iommu_group`.

    Update your `variables.auto.tfvars` with these values.

5.  **Reboot Proxmox Host**.

### 2. Deployment Order & Token Retrieval

> **WARNING**: The **K3s Controller** must be fully provisioned and running *before* you can deploy the GPU Worker.

The worker node requires the K3s server token to join the cluster.

1.  **Deploy Controller**:
    Ensure the `k3s-controller` module is applied and the VM is running.
2.  **Retrieve Token**:
    SSH into the controller and fetch the node token:
    ```bash
    ssh <controller-user>@<controller-ip> "sudo -S cat /var/lib/rancher/k3s/server/node-token"
    ```
3.  **Configure Secrets**:
    Add the token to your `secrets.auto.tfvars` (or `variables.auto.tfvars` if not treating as secret):
    ```hcl
    k3s_token = "K10..."
    ```
4.  **Deploy Worker**:
    Run `make apply k3s-gpu-worker` to provision the worker node. You will be prompted for the K3s Controller sudo password.
    
5. *Verification*:
    Run `kubectl describe node <worker-node>` and check for `nvidia.com/gpu: 1` under Capacity.

## Initial Deployment

1. Initialize the Terraform working directory:

   ```bash
   terraform init
   terraform get
   ```
2. Review the execution plan:

   ```bash
   terraform plan
   ```
3. Apply the configuration to create the resources:

   ```bash
   terraform apply
   ```

You can also use the makefile for convenience:

```bash
make init
make plan
make apply
```

## Subsequent Deployments

I do not recommend using `terraform apply` for subsequent deployments as it may 
overwrite some resources. Instead, I supply a makefile with targets for creating
and destroying specific resources. For example, if you only want to recreate
the dev VM from scratch, you can use `make destroy-dev-vm` followed by `make dev-vm`.

## Security disclaimer

I use this repository to self host services for my personal use only. Albeit I
do try to harden as much as possible, there are points where I had to make tradeoffs between security and convenience. I make no guarantee or promises of implementing 
enterprise-grade security practices, and I do not recommend using this code as is for production environments or for hosting sensitive data. And I definitely do not recommend using this code for hosting services that are exposed to the public internet. I am not liable for any security breaches or data loss that may occur as a result of using this code. Use at your own risk.

## IA disclaimer

The code used in this repository was partially generated by an AI assistant. Since
infrastructure as code is a new area for me, I am using this repository not only to 
gain experience with IaC, but also to improve my skills in using AI assistants for code generation and review.

That said, I want to be transparent about the fact that while AI was used to generate some of the code, it was not blindly accepted. In this repository, I have made sure to review and test all AI-generated code, and I have only included code that I am confident works as intended. There are also parts of the code that were manually written by me without any AI assistance.

My process when using AI follows the loop

1. Ask AI assistant (typically Claude or Gemini) to recommend initial architecture for 
   the specific service (use VM, containers, how to configure network, etc).
2. Review the code, manually implementing changes according to my needs or where I
   believe the code is suboptimal/will not work.
3. Test the code and make sure it works as expected.
4. If it doesn't work, diagnose using combo of debugging using my own experience,
   online resources and AI assistant.
5. Once task is finished, commit changes to the repository.

