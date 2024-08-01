#!/bin/bash

# Define threshold values
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
LOG_FILE="/var/log/system_health.log"

# Function to get CPU usage
get_cpu_usage() {
  # Calculate CPU usage
  local cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d ',')
  local cpu_usage=$(echo "100 - $cpu_idle" | bc)
  echo $cpu_usage
}

# Function to get memory usage
get_memory_usage() {
  # Get the memory usage percentage
  local total_mem=$(free -m | awk '/^Mem:/ {print $2}')
  local used_mem=$(free -m | awk '/^Mem:/ {print $3}')
  local mem_usage=$(echo "scale=2; $used_mem/$total_mem*100" | bc)
  echo $mem_usage
}

# Function to get disk usage
get_disk_usage() {
  # Get the root filesystem usage percentage
  local disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
  echo $disk_usage
}

# Function to get the number of running processes
get_running_processes() {
  # Count the number of running processes
  local processes=$(ps aux | wc -l)
  echo $processes
}

# Function to log alerts
log_alert() {
  local message=$1
  echo "$(date +'%Y-%m-%d %H:%M:%S') - ALERT: $message" | tee -a $LOG_FILE
}

# Check CPU usage
cpu_usage=$(get_cpu_usage)
if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
  log_alert "High CPU usage detected: $cpu_usage%"
fi

# Check memory usage
memory_usage=$(get_memory_usage)
if (( $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc -l) )); then
  log_alert "High memory usage detected: $memory_usage%"
fi

# Check disk usage
disk_usage=$(get_disk_usage)
if (( $disk_usage > $DISK_THRESHOLD )); then
  log_alert "High disk usage detected: $disk_usage%"
fi

# Check number of running processes
running_processes=$(get_running_processes)
log_alert "Number of running processes: $running_processes"

# End 
