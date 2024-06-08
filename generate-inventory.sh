#!/bin/bash
IP_ADDRESS=$(cat ip_address.txt)
cat <<EOL > inventory
[minecraft]
$IP_ADDRESS ansible_ssh_user=ec2-user ansible_ssh_private_key_file=~/.ssh/mc-server-key.pem
EOL
