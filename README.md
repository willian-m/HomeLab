# Home Lab deployment with Terraform and Proxmox

This repository contains Terraform configurations to deploy and manage a home lab environment using Proxmox as the virtualization platform. This setup assumes you have a Proxmox server up and running and accessible via the network.

## Motivation

I had some spare hardware lying around and wanted to experiment
some self-hosted services. One thing lead to another and I learned about proxmox. Once I set up one or two services, it
quickly became apparent that managing everything manually and 
keeping documentation up to date was going to be a pain. Hence, I decided it would be the perfect opportunity to lear Terraform and infra as a code.

Services included will grow over time as my personal needs evolve. Also, I hope this to be useful for others looking to set up a similar environment.

## Features

Currently, the setup includes:

- Dev VM for remote development and testing of projects.

## Prerequisites

- Proxmox VE installed and configured on a server which you have root access.
- Access to a Proxmox API token or user credentials with sufficient permissions.
- SSH key pair for secure access to the VMs.
- `mkpasswd` utility to generate hashed passwords.

## Configuration

1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Edit the `variables.tfvars` file to set your Proxmox server details, VM specifications, and other configurations.
4. Edit the `secrets.auto.tfvars` file to set sensitive information like API tokens and passwords. Make sure this file is not committed to version control.

## Deployment

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
