#!/bin/bash
set -e  # Exit on error

# Ensure lsof is installed
if ! command -v lsof &> /dev/null; then
    echo "Installing lsof..."
    sudo apt update && sudo apt install -y lsof
fi

# Display currently running Gaia nodes
echo "Checking for running Gaia nodes..."
echo -e "PID       Base Folder                Port"
echo "------------------------------------------------------"
ps aux | grep gaias | grep -v grep | awk '{for(i=1;i<=NF;i++) if ($i ~ /--server-socket-addr/) print $2, $(i+1), $(i+3)}' | awk -F: '{print $1, $2, $3}'
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
NODE_DIR=$HOME/gaia-node-$NODE_NUM
echo "Installing Gaia node in: $NODE_DIR"

# Create folder for the new node
mkdir -p $NODE_DIR

# Install Gaia node
echo "Installing Gaia node..."
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base "$NODE_DIR"

# Add the gaianet binary to PATH if it's not already there
if ! command -v gaianet &> /dev/null; then
    echo "Adding gaianet to PATH..."
    if [[ -f "$NODE_DIR/bin/gaianet" ]]; then
        export PATH="$PATH:$NODE_DIR/bin"
    else
        echo "Error: gaianet binary not found at $NODE_DIR/bin/gaianet"
        echo "Installation may have failed or installed to a different location"
        exit 1
    fi
fi

# Configure Gaia node with better error handling
echo "Configuring Gaia node..."
echo "Downloading config from: $CONFIG_URL"
if ! gaianet init --base "$NODE_DIR" --config "$CONFIG_URL"; then
    echo "Error during init with config URL. Trying alternative approach..."
    # Download config file manually and then init
    CONFIG_FILE="$NODE_DIR/config.json"
    if curl -sSfL "$CONFIG_URL" -o "$CONFIG_FILE"; then
        gaianet init --base "$NODE_DIR" --config-file "$CONFIG_FILE"
    else
        echo "Failed to download config file"
        exit 1
    fi
fi

echo "Setting port to: $PORT_NUM"
gaianet config --base "$NODE_DIR" --port "$PORT_NUM"

# Start Gaia node
echo "Starting Gaia node..."
if sudo lsof -t -i:"$PORT_NUM" &> /dev/null; then
    echo "Port $PORT_NUM is in use. Attempting to free it..."
    sudo lsof -t -i:"$PORT_NUM" | xargs -r sudo kill -9
    sleep 2
fi

gaianet start --base "$NODE_DIR" &
sleep 5

# Display node info
echo "Displaying node info:"
gaianet info --base "$NODE_DIR"
