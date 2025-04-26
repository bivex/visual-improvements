#!/bin/bash

# System Performance Analyzer
# This script identifies processes that negatively impact system performance

# Check if a command exists and is executable
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for basic dependencies
check_basic_dependencies() {
    local missing_deps=()
    for cmd in ps free top; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "ERROR: Missing critical tools: ${missing_deps[*]}"
        echo "Please install procps-ng package"
        exit 1
    fi
}

# Format the output with colors and headers
print_header() {
    echo -e "\e[1;34m$1\e[0m"
    echo -e "\e[1;34m$(printf '=%.0s' {1..50})\e[0m"
}

# Get top CPU consuming processes
analyze_cpu() {
    print_header "TOP CPU CONSUMERS"
    echo "Displaying processes using high CPU resources:"
    ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 11
    
    echo -e "\nCPU load analysis:"
    if command_exists mpstat; then
        mpstat -P ALL 1 3 | grep -v CPU | awk '$2 ~ /[0-9]/ && $3 + $4 + $5 > 50 {print "Core " $2 " is heavily loaded: " $3+$4+$5 "% utilized"}'
    else
        echo "CPU detailed stats not available. Install sysstat package for more detailed CPU analysis."
        echo "Current CPU load: $(uptime | sed -e 's/.*load average: //')"
    fi
    
    echo -e "\nProcess count per user:"
    ps hax -o user | sort | uniq -c | sort -rn
}

# Get top memory consuming processes
analyze_memory() {
    print_header "TOP MEMORY CONSUMERS"
    echo "Displaying processes using high memory resources:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11

    echo -e "\nMemory usage summary:"
    free -h
    
    echo -e "\nSwap usage per process (if any swap is used):"
    if [[ $(free | grep Swap: | awk '{print $3}') -gt 0 ]]; then
        echo "PID USERNAME SWAP(KB) COMMAND"
        for file in /proc/*/status; do
            awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' "$file" 2>/dev/null | grep -v "^$" | sort -k 2 -n -r | head -n 10 | while read -r name swap; do
                if [[ "$swap" != "0" && "$swap" != "" ]]; then
                    pid=$(echo "$file" | cut -d / -f 3)
                    user=$(ps -o user= -p "$pid" 2>/dev/null)
                    cmd=$(ps -o comm= -p "$pid" 2>/dev/null)
                    if [[ -n "$user" && -n "$cmd" ]]; then
                        printf "%-8s %-10s %-8s %s\n" "$pid" "$user" "$swap" "$cmd"
                    fi
                fi
            done
        done
    else
        echo "No swap is currently being used"
    fi
}

# Get disk I/O stats
analyze_disk() {
    print_header "DISK I/O ANALYSIS"
    echo "Processes with highest disk I/O activity:"
    
    # Check for iotop
    if command_exists iotop; then
        echo "Running iotop for 5 seconds (press Ctrl+C to interrupt)..."
        sudo timeout 5 iotop -o -b -n 2 | head -n 20
    elif command_exists iostat; then
        echo "I/O statistics:"
        iostat -d -x 1 3 | grep -v "^$" | grep -v "Linux"
    else
        echo "For detailed I/O analysis, install 'sysstat' (for iostat) or 'iotop' package"
        echo "Displaying large files that might cause I/O load:"
        df -h
    fi
    
    echo -e "\nLarge files recently modified (potentially causing I/O):"
    find /var/log -type f -size +10M -mtime -1 2>/dev/null | head -n 5
    find /tmp -type f -size +10M -mtime -1 2>/dev/null | head -n 5
}

# Analyze network connections and traffic
analyze_network() {
    print_header "NETWORK ANALYSIS"
    echo "Current network connections:"
    
    if command_exists ss; then
        ss -tunapl | grep -v "LISTEN" | head -n 10
    elif command_exists netstat; then
        netstat -tunapl 2>/dev/null | grep -v "LISTEN" | head -n 10
    else
        echo "Network connection analysis requires 'ss' or 'netstat'"
    fi
    
    echo -e "\nProcesses with network activity:"
    if command_exists nethogs; then
        echo "For real-time network usage by process, run: sudo nethogs"
    else
        echo "Install 'nethogs' package for per-process network usage"
    fi
    
    # Check for unusual ports or connections
    if command_exists lsof; then
        echo -e "\nUnusual network ports (not common services):"
        lsof -i -n -P 2>/dev/null | grep -v ":22\|:80\|:443\|:53\|:8080" | head -n 10
    fi
}

# Check for resource-intensive systemd services
analyze_services() {
    print_header "SYSTEMD SERVICES ANALYSIS"
    
    if command_exists systemctl; then
        if command_exists systemd-cgtop; then
            echo "Top resource-consuming services:"
            systemd-cgtop -n1 | head -n 10
        fi
        
        echo -e "\nRecently failed services (may impact performance):"
        systemctl --failed
        
        if command_exists systemd-analyze; then
            echo -e "\nSlower starting services (bootup bottlenecks):"
            systemd-analyze blame | head -n 5
        fi
    else
        echo "Systemd analysis requires systemd-based system"
    fi
}

# Check scheduled tasks that might affect performance
analyze_scheduled_tasks() {
    print_header "SCHEDULED TASKS ANALYSIS"
    
    echo "Active cron jobs that might impact performance:"
    if command_exists crontab; then
        for user in $(cut -f1 -d: /etc/passwd); do
            crontab -u "$user" -l 2>/dev/null | grep -v "^#" | grep -v "^$" | sed "s/^/$user: /"
        done
    else
        echo "Crontab utility not found"
    fi
    
    echo -e "\nSystemd timers:"
    if command_exists systemctl; then
        systemctl list-timers --all 2>/dev/null | head -n 10
    else
        echo "Systemd timers analysis requires systemd-based system"
    fi
}

# Main analysis report function
generate_report() {
    clear
    echo "========================================================"
    echo "            SYSTEM PERFORMANCE ANALYSIS                 "
    echo "========================================================"
    echo "System: $(uname -a)"
    echo "Time: $(date)"
    echo "Uptime: $(uptime)"
    echo "========================================================" 
    echo ""
    
    analyze_cpu
    echo ""
    
    analyze_memory
    echo ""
    
    analyze_disk
    echo ""
    
    analyze_network
    echo ""
    
    analyze_services
    echo ""
    
    analyze_scheduled_tasks
    echo ""
    
    print_header "PERFORMANCE RECOMMENDATIONS"
    echo "Based on the analysis, consider checking:"
    echo "1. Processes with high CPU/memory usage"
    echo "2. Excessive swap usage (if any)"
    echo "3. Disk I/O bottlenecks" 
    echo "4. Failed services or slow boot services"
    echo "5. Unexpected network connections"
    echo ""
    echo "To get more detailed analysis, consider installing:"
    if ! command_exists iostat || ! command_exists mpstat; then
        echo "- sysstat (for iostat, mpstat - detailed CPU and I/O analysis)"
    fi
    if ! command_exists iotop; then
        echo "- iotop (for I/O monitoring)"
    fi
    if ! command_exists nethogs; then
        echo "- nethogs (for network monitoring)"
    fi
    if ! command_exists htop; then
        echo "- htop (interactive process viewer)"
    fi
    if ! command_exists glances; then
        echo "- glances (system monitor)"
    fi
}

# Check if running as root for full access
if [[ $EUID -ne 0 ]]; then
    echo "Warning: Not running as root. Some information may be limited."
    echo "For complete analysis, run with sudo: sudo $0"
    echo ""
fi

# Run the analysis
check_basic_dependencies
generate_report

echo ""
echo "Analysis complete. To save this report to a file, run:"
echo "sudo $0 > performance_report.txt" 