# Terraform and Ansible Automation

This project automates the creation of EC2 instances with Terraform and the deployment of machine learning tools using Ansible.

## Prerequisites

- AWS CLI configured with appropriate credentials.
- Terraform installed.
- Ansible installed.
- jq installed.
- sshpass installed.

## Getting Started

1. **Clone the Repository:**

   ```sh
   git clone https://github.com/07prince/Dev_Ops.git
   cd Dev_Ops


# terraform install
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Ansible install
sudo apt update
sudo apt install -y ansible

# jq installed and sshpass installed
sudo apt-get install -y jq sshpass

