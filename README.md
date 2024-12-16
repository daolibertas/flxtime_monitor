# FLXTime Monitor Installation Script

This script is designed to monitor the status of a wallet on FLXTime by sending periodic requests to a specified URL and logging the results. It sets up a cron job to run every minute and ensures all required dependencies are installed.

---

## Features

- **Automated Installation**:
  - Installs required tools like `jq` (for JSON parsing).
  - Sets up the monitoring script with user-provided parameters.
  - Configures cron to run the monitoring script every minute.
- **Customizable Monitoring**:
  - Accepts user input for the wallet address and monitoring URL.
  - Logs results in a structured format.
- **Log Management**:
  - Creates a daily log file in a specified directory.

---

## Requirements

- A Linux-based system with:
  - `bash` shell
  - `curl` command
  - Cron service
---

## Installation Steps

### 1. Clone or Download the Script
Download the script file to your machine or copy its content to a file named `install_flxtime_monitor.sh`.

### 2. Make the Script Executable
Run the following command to make the script executable:
```bash
chmod +x install_flxtime_monitor.sh
```

### 3. Run the Script
Execute the script with:
```bash
sudo ./install_flxtime_monitor.sh
```

### 4. Provide Input
The script will prompt you for:
- **Wallet Address**: The wallet to monitor.
---

## File and Directory Structure

### 1. Monitoring Script
The main script is installed at:
```
/usr/local/bin/flxtime_monitor.sh
```

### 2. Log Directory
Logs are stored in:
```
/var/log/miner_flxtime_monitor/
```
Each day's log is named in the format:
```
miner_status_<YYYY-MM-DD>.log
```

### 3. Cron Job
The cron job runs every minute and ensures the monitoring script is executed. You can view the job with:
```bash
crontab -l
```

---

## How It Works

1. **Monitoring Script**:
   - Sends a request to the provided URL using `curl`.
   - Parses the JSON response with `jq`.
   - Logs the result, including a timestamp, to a daily log file.
   
2. **Cron Setup**:
   - The script clears any existing cron jobs and adds a new job to run the monitoring script every minute.

3. **Log Management**:
   - Logs are appended to daily log files for easy organization and debugging.

---

## Customization

### Changing the Log Directory
Edit the `LOG_DIR` variable in the script to specify a new location for log files.

---

## Example Output

### JSON Response from the API:
```json
{
  "status": "success",
  "message": "Miner data",
  "data": {
    "wallet": "your_wallet",
    "proof_count": 42,
    "total_reward": "XXX",
    "locked_rewards": "XXX",
    "locked_since": "2024-12-01T00:00:00.000Z",
    "last_connected": "2024-01-01T00:00:00.000Z",
    "last_proof_time": "2024-01-01T00:00:00.000Z",
    "status": "ON",
    "blocklist": false,
    "last_rewarded_at": null
  }
}
```

### Example Log Entry:
```
2024-12-16 11:00:00 - Status is OK: status=success, data.status=ON
```

---

## Troubleshooting

### Check Logs
If the monitoring script is not working as expected, check the log files in `/var/log/miner_flxtime_monitor/`.

### Verify Cron Job
Ensure the cron job is set up correctly by running:
```bash
crontab -l
```

### Manually Run the Monitoring Script
You can manually test the monitoring script with:
```bash
/usr/local/bin/flxtime_monitor.sh
```

---

## Uninstallation

1. Remove the monitoring script:
   ```bash
   sudo rm /usr/local/bin/flxtime_monitor.sh
   ```

2. Remove the log directory:
   ```bash
   sudo rm -r /var/log/miner_flxtime_monitor/
   ```

3. Clear the cron job:
   ```bash
   crontab -r
   ```

---

## Notes

- Ensure your system's cron service is running:
  ```bash
  sudo systemctl status cron
  ```
- Make sure you have sufficient permissions to install dependencies and configure cron.

---

### Command to Analyze Log Files

To count the occurrences of `Status is OK` and compare them to the total number of lines in a specific log file, run:

```bash
LOG_FILE="/var/log/miner_flxtime_monitor/miner_status_<YYYY-MM-DD>.log"
OK_COUNT=$(grep -c "Status is OK" "$LOG_FILE")
TOTAL_COUNT=$(wc -l < "$LOG_FILE")
echo "OK: $OK_COUNT, Total: $TOTAL_COUNT, Ratio: $(awk "BEGIN {printf \"%.2f\", ($OK_COUNT/$TOTAL_COUNT)*100}")%"
```

### Explanation:
1. **Replace `<YYYY-MM-DD>`** with the desired date of the log file.
2. **Commands used**:
   - `grep -c "Status is OK"`: Counts the lines containing `Status is OK`.
   - `wc -l`: Counts the total lines in the log file.
   - `awk`: Calculates the percentage of `Status is OK` lines compared to the total.
3. **Output**:
   - Number of `OK` lines.
   - Total lines in the file.
   - Percentage of `Status is OK` lines.

---

## License

This script is provided as-is under the MIT License. You are free to use, modify, and distribute it.
