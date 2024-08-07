#!/bin/bash

# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve

# Extract the public IPs of the instances
ANSIBLE_SERVER_IP=$(terraform output -raw ansible_server_ip)
TARGET_INSTANCE_IPS=$(terraform output -json target_instance_ips | jq -r '.[]')

echo "Ansible Server IP: $ANSIBLE_SERVER_IP"
echo "Target Instance IPs: $TARGET_INSTANCE_IPS"

# Generate SSH key pair on Ansible server
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa_ansible -N ""

# Copy the public key to target instances
for ip in $TARGET_INSTANCE_IPS; do
  ssh-keyscan -H $ip >> ~/.ssh/known_hosts
  ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ubuntu@$ip
done

# Create Ansible inventory file
cat <<EOF > hosts
[targets]
$(echo $TARGET_INSTANCE_IPS | tr ' ' '\n')

[targets:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible
ansible_user=ubuntu
EOF

# Create Ansible playbook
cat <<EOF > ml_tools.yml
---
- hosts: targets
  become: yes
  tasks:
    - name: Update and upgrade apt packages
      apt:
        update_cache: yes
        upgrade: dist

    - name: Install Python and pip
      apt:
        name:
          - python3
          - python3-pip
        state: present

    - name: Install Jupyter Notebook
      pip:
        name: jupyter

    - name: Install Python data science libraries
      pip:
        name:
          - numpy
          - pandas
          - scipy
          - scikit-learn
          - matplotlib
          - seaborn

    - name: Install R
      apt:
        name: r-base
        state: present

    - name: Install R libraries
      command: R -e "install.packages(c('ggplot2', 'dplyr', 'tidyr'), repos='http://cran.rstudio.com/')"
EOF

# Run Ansible playbook
ansible-playbook -i hosts ml_tools.yml
