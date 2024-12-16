#!/bin/bash

# Variables
MONITOR_SCRIPT="/usr/local/bin/flxtime_monitor.sh"
LOG_DIR="/var/log/miner_flxtime_monitor"
CRON_USER=$(whoami)

# Messages
MSG_JQ_CHECK="Checking if 'jq' is installed..."
MSG_JQ_INSTALL="Installing 'jq'..."
MSG_LOG_DIR="Creating log directory..."
MSG_MONITOR_SCRIPT="Creating monitoring script..."
MSG_CRON_SETUP="Setting up cron job..."
MSG_CRON_CLEAR="Clearing existing cron jobs..."
MSG_COMPLETION="Installation complete. Details:"
MSG_ERROR_JQ="Error: Could not install 'jq'. Please install it manually and rerun this script."

# Prompt for wallet and URL
read -p "Enter your wallet: " WALLET
URL=${URL:-"https://mine.flxtime.click/miner/$WALLET"}

# Check if jq is installed
echo "$MSG_JQ_CHECK"
if ! command -v jq &> /dev/null; then
    echo "$MSG_JQ_INSTALL"
    if [[ -x "$(command -v apt)" ]]; then
        sudo apt update && sudo apt install -y jq
    elif [[ -x "$(command -v yum)" ]]; then
        sudo yum install -y jq
    elif [[ -x "$(command -v dnf)" ]]; then
        sudo dnf install -y jq
    else
        echo "$MSG_ERROR_JQ"
        exit 1
    fi
fi

# Create log directory
echo "$MSG_LOG_DIR"
sudo mkdir -p "$LOG_DIR"
sudo chown "$CRON_USER:$CRON_USER" "$LOG_DIR"

# Create monitoring script
echo "$MSG_MONITOR_SCRIPT"
cat <<EOF | sudo tee "$MONITOR_SCRIPT" > /dev/null
#!/bin/bash

# Variables
URL="$URL"
LOG_FILE="$LOG_DIR/miner_status_\$(date +'%Y-%m-%d').log"

# Perform a cURL request to get JSON data
RESPONSE=\$(curl -s "\$URL")

# Extract "status" and "data.status" values using jq
STATUS=\$(echo "\$RESPONSE" | jq -r '.status')
DATA_STATUS=\$(echo "\$RESPONSE" | jq -r '.data.status')

# Check conditions and write to log
if [[ "\$STATUS" == "success" && "\$DATA_STATUS" == "ON" ]]; then
    echo "\$(date) - Status is OK: status=\$STATUS, data.status=\$DATA_STATUS" >> "\$LOG_FILE"
else
    echo "\$(date) - WARNING: status=\$STATUS, data.status=\$DATA_STATUS" >> "\$LOG_FILE"
fi
EOF

# Make the monitoring script executable
sudo chmod +x "$MONITOR_SCRIPT"

# Clear existing crontab and set up a new one
echo "$MSG_CRON_CLEAR"
crontab -r 2>/dev/null
echo "$MSG_CRON_SETUP"
(crontab -l 2>/dev/null; echo "* * * * * $MONITOR_SCRIPT") | crontab -

# Completion message
echo "$MSG_COMPLETION
- Monitoring script: $MONITOR_SCRIPT
- Log directory: $LOG_DIR
- Cron job added to run every minute.
"

