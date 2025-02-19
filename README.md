# Gaia Node Setup Script

## Overview
This script automates the installation and configuration of Gaia nodes. It allows users to specify a node number, port, and model configuration before setting up the node. Additionally, it detects and displays currently running Gaia nodes along with their ports.

## Prerequisites
- Ensure you have `bash` installed.
- The script requires `lsof` to check for running processes. If not installed, the script will install it automatically.

## Installation & Usage
1. Download or clone this repository.
2. Navigate to the directory containing the script.
3. Run the script using:
   ```bash
   bash setup_gaia_node.sh
   ```
4. Follow the on-screen prompts to enter the node number, port, and select the model configuration.

## Features
- Lists currently running Gaia nodes with their ports.
- Allows the user to specify the node number and port.
- Supports different model configurations.
- Automatically installs missing dependencies.

## Example Output
```
Checking for running Gaia nodes...
Currently running Gaia nodes:
PID       IP              Port   Base Folder
------------------------------------------------------
1351351   127.0.0.1       8080   /root/gaia-node-103
1351733   127.0.0.1       8103   /root/gaia-node-102
1439178   127.0.0.1       8104   /root/gaia-node-104
2405387   127.0.0.1       8106   /root/gaia-node-106
2409267   127.0.0.1       8107   /root/gaia-node-107
------------------------------------------------------
```

## Notes
- If a Gaia node is already running on the specified port, the user will be prompted to enter a different port.
- The script sources the `.bashrc` file after installation to apply necessary changes.

## Support
For any issues or suggestions, feel free to reach out!

