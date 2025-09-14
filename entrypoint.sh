#!/bin/bash

# --- Generate SSH Key if it doesn't exist ---
if [ ! -f /home/ansible/.ssh/id_rsa ]; then
    echo ">>> Generating SSH key for ansible user..."
    ssh-keygen -t rsa -b 4096 -f /home/ansible/.ssh/id_rsa -N ""
fi

# --- Automatically copy SSH key to all managed nodes ---
TOTAL_NODES=7
echo ">>> Starting SSH key distribution to $TOTAL_NODES managed nodes..."

for i in $(seq 1 $TOTAL_NODES); do
    NODE_NAME="managed-node-$i"
    echo ">>> Waiting for $NODE_NAME to be ready..."

    # Loop until the SSH port is open on the node
    until nc -z $NODE_NAME 22; do
        sleep 1
    done

    echo ">>> $NODE_NAME is ready. Adding its host key to known_hosts..."
    ssh-keyscan -H $NODE_NAME >> /home/ansible/.ssh/known_hosts

    echo ">>> Copying SSH key to $NODE_NAME..."
    sshpass -p 'ansible' ssh-copy-id -o StrictHostKeyChecking=no ansible@$NODE_NAME
done

echo "*****************************************************"
echo "**                                                 **"
echo "**  LAB SETUP COMPLETE! All keys are distributed.  **"
echo "**                                                 **"
echo "*****************************************************"

# Keep the container running
tail -f /dev/null
