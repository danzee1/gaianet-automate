#!/bin/bash

# Ensure lsof is installed
if ! command -v lsof &> /dev/null; then
    echo "Installing lsof..."
    sudo apt update && sudo apt install -y lsof
fi

# Display currently running Gaia nodes
echo "Checking for running Gaia nodes..."
echo -e "PID       Base Folder                Port"
echo "------------------------------------------------------"
ps aux | grep gaias | awk '{for(i=1;i<=NF;i++) if ($i ~ /--server-socket-addr/) print $2, $(i+1), $(i+3)}' | awk -F: '{print $1, $2, $3}'
echo "------------------------------------------------------"

# Ask user for node number and port
echo -n "Enter the node number to install (e.g., 106): "
read NODE_NUM
echo -n "Enter the port number for this node (e.g., 8106): "
read PORT_NUM

# Ask user for model configuration
echo "Select the model configuration:"
echo "1) Qwen1.5-0.5b-Chat"
echo "2) Qwen2-0.5b-Instruct"
echo -n "Enter choice (1 or 2): "
read MODEL_CHOICE

if [[ "$MODEL_CHOICE" == "1" ]]; then
    CONFIG_URL="https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen-1.5-0.5b-chat/config.json"
elif [[ "$MODEL_CHOICE" == "2" ]]; then
    CONFIG_URL="https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen2-0.5b-instruct/config.json"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Define node directory
NODE_DIR="$HOME/gaia-node-$NODE_NUM"

# Create folder for the new node
mkdir -p "$NODE_DIR"

# Install Gaia node
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base "$NODE_DIR"
source $HOME/.bashrc

# Configure Gaia node
gaianet init --base "$NODE_DIR" --config "$CONFIG_URL"

gaianet config --base "$NODE_DIR" --port "$PORT_NUM"

gaianet init --base "$NODE_DIR"

# Start Gaia node
sudo lsof -t -i:"$PORT_NUM" | xargs kill -9
gaianet start --base "$NODE_DIR"

# Display node info
gaianet info --base "$NODE_DIR"
