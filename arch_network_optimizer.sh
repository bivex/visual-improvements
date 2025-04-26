#!/bin/bash

# Arch Linux Network Optimizer
# This script optimizes network settings for better performance

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root!${NC}"
    echo "Please run with sudo: sudo $0"
    exit 1
fi

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}======================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}======================================================${NC}"
}

# Function to backup files before modifying
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak.$(date +%Y%m%d)"
        echo -e "Created backup: ${file}.bak.$(date +%Y%m%d)"
    fi
}

# Function to prompt for yes/no confirmation
confirm() {
    local prompt="$1"
    local default="$2"
    
    local yn
    if [[ "$default" == "Y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -r -p "$prompt" yn
    
    if [[ "$default" == "Y" ]]; then
        [[ "$yn" == [nN] ]] && return 1
        return 0
    else
        [[ "$yn" == [yY] ]] && return 0
        return 1
    fi
}

# Get primary network interface
get_primary_interface() {
    # Get the interface with default route
    local interface=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
    if [[ -z "$interface" ]]; then
        # Fallback to first active interface
        interface=$(ip -o -4 addr show | grep 'state UP' | awk '{print $2}' | cut -d':' -f1 | head -n1)
    fi
    echo "$interface"
}

# Optimize kernel network parameters
optimize_kernel_parameters() {
    print_header "OPTIMIZING KERNEL NETWORK PARAMETERS"
    
    echo "Creating network optimizer sysctl configuration..."
    backup_file "/etc/sysctl.d/99-network-performance.conf"
    
    cat > "/etc/sysctl.d/99-network-performance.conf" << EOF
# Network performance optimization parameters

# Increase system file descriptor limit
fs.file-max = 100000

# TCP memory allocation settings
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 16777216
net.ipv4.tcp_wmem = 4096 1048576 16777216

# TCP congestion control
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# TCP fast open for faster connection establishment
net.ipv4.tcp_fastopen = 3

# TCP connection optimization
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10

# Protect against TCP time-wait assassination
net.ipv4.tcp_rfc1337 = 1

# Disable TCP slow start on idle connections
net.ipv4.tcp_slow_start_after_idle = 0

# Increase number of incoming connections backlog
net.core.somaxconn = 8192

# Increase number of incoming connections
net.core.netdev_max_backlog = 16384

# Increase max number of open files
fs.nr_open = 1048576
EOF
    
    echo "Applying new sysctl parameters..."
    sysctl --system
    
    # Verify BBR is available
    local bbr_available=$(lsmod | grep bbr || echo "")
    if [[ -z "$bbr_available" ]]; then
        echo -e "${YELLOW}TCP BBR congestion control might not be available in your kernel.${NC}"
        echo "It's recommended to use a kernel version 4.9 or later."
        echo "Current kernel: $(uname -r)"
    else
        echo -e "${GREEN}TCP BBR congestion control is enabled.${NC}"
    fi
    
    echo -e "${GREEN}Kernel network parameters optimized.${NC}"
}

# Configure DNS for faster name resolution
optimize_dns() {
    print_header "OPTIMIZING DNS SETTINGS"
    
    echo "Current DNS servers:"
    grep "nameserver" /etc/resolv.conf | sed 's/nameserver/- /'
    
    if confirm "Would you like to use faster public DNS servers?" "Y"; then
        echo "Select DNS provider:"
        echo "1) Cloudflare (1.1.1.1, 1.0.0.1) - Focus on privacy and speed"
        echo "2) Google (8.8.8.8, 8.8.4.4) - Reliable and widely used"
        echo "3) Quad9 (9.9.9.9, 149.112.112.112) - Focus on security"
        echo "4) OpenDNS (208.67.222.222, 208.67.220.220) - Security features"
        read -r -p "Enter choice [1-4]: " dns_choice
        
        backup_file "/etc/resolv.conf"
        
        local dns_servers
        case $dns_choice in
            1) dns_servers=("1.1.1.1" "1.0.0.1")
               echo "Setting up Cloudflare DNS..." ;;
            2) dns_servers=("8.8.8.8" "8.8.4.4")
               echo "Setting up Google DNS..." ;;
            3) dns_servers=("9.9.9.9" "149.112.112.112")
               echo "Setting up Quad9 DNS..." ;;
            4) dns_servers=("208.67.222.222" "208.67.220.220")
               echo "Setting up OpenDNS..." ;;
            *) echo -e "${YELLOW}Invalid choice. Keeping current DNS.${NC}"
               return ;;
        esac
        
        # Check if systemd-resolved is in use
        if systemctl is-active systemd-resolved &> /dev/null; then
            echo "systemd-resolved is active, configuring it..."
            backup_file "/etc/systemd/resolved.conf"
            
            local dns_line="DNS=${dns_servers[0]} ${dns_servers[1]}"
            
            # Update resolved.conf
            if grep -q "^#DNS=" /etc/systemd/resolved.conf; then
                sed -i "s/^#DNS=.*/$dns_line/" /etc/systemd/resolved.conf
            elif grep -q "^DNS=" /etc/systemd/resolved.conf; then
                sed -i "s/^DNS=.*/$dns_line/" /etc/systemd/resolved.conf
            else
                echo "$dns_line" >> /etc/systemd/resolved.conf
            fi
            
            # Enable DNSOverTLS if supported
            if grep -q "DNSOverTLS" /etc/systemd/resolved.conf; then
                sed -i "s/^#\?DNSOverTLS=.*/DNSOverTLS=opportunistic/" /etc/systemd/resolved.conf
            else
                echo "DNSOverTLS=opportunistic" >> /etc/systemd/resolved.conf
            fi
            
            systemctl restart systemd-resolved
        else
            # Direct resolv.conf update
            cat > "/etc/resolv.conf" << EOF
# Generated by network optimizer script
nameserver ${dns_servers[0]}
nameserver ${dns_servers[1]}
options timeout:1
options attempts:5
EOF
        fi
        
        echo -e "${GREEN}DNS settings optimized.${NC}"
    fi
}

# Setup network interface settings
optimize_interface() {
    local interface=$(get_primary_interface)
    
    print_header "OPTIMIZING NETWORK INTERFACE: $interface"
    
    if [[ -z "$interface" ]]; then
        echo -e "${RED}No active network interface found.${NC}"
        return
    fi
    
    echo "Current settings for $interface:"
    echo "Stats:"
    ethtool -S "$interface" 2>/dev/null | grep -E 'drop|collision|error' | grep -v ':0$' || echo "No error stats available"
    
    # Check if interface supports features optimization
    local supports_features=false
    if ethtool -k "$interface" &>/dev/null; then
        supports_features=true
        echo -e "\nCurrent offload settings:"
        ethtool -k "$interface" | grep -E 'tcp-segmentation-offload|generic-segmentation-offload|generic-receive-offload|rx-checksumming|tx-checksumming'
    fi
    
    # Check interface ring buffer
    local supports_ring=false
    if ethtool -g "$interface" &>/dev/null; then
        supports_ring=true
        echo -e "\nCurrent ring buffer settings:"
        ethtool -g "$interface"
    fi
    
    # Check interface coalesce parameters
    local supports_coalesce=false
    if ethtool -c "$interface" &>/dev/null; then
        supports_coalesce=true
        echo -e "\nCurrent interrupt coalescing settings:"
        ethtool -c "$interface"
    fi
    
    if confirm "Would you like to optimize $interface settings?" "Y"; then
        # Create a systemd service to apply settings on boot
        mkdir -p /etc/systemd/system
        
        cat > "/etc/systemd/system/network-optimizer@.service" << EOF
[Unit]
Description=Network Interface Optimization for %I
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c "
EOF
        
        # Add optimization commands to service file
        if [[ "$supports_features" == true ]]; then
            echo "echo 'Enabling TCP/RX/TX offloading for %I...'" >> "/etc/systemd/system/network-optimizer@.service"
            echo "/usr/bin/ethtool -K %I tso on gso on gro on rx on tx on" >> "/etc/systemd/system/network-optimizer@.service"
        fi
        
        if [[ "$supports_ring" == true ]]; then
            echo "echo 'Optimizing ring buffer for %I...'" >> "/etc/systemd/system/network-optimizer@.service"
            echo "current=\$(/usr/bin/ethtool -g %I | grep -A 1 'Current hardware settings' | tail -1 | awk '{print \$1}')" >> "/etc/systemd/system/network-optimizer@.service"
            echo "maximum=\$(/usr/bin/ethtool -g %I | grep -A 1 'Pre-set maximums' | tail -1 | awk '{print \$1}')" >> "/etc/systemd/system/network-optimizer@.service"
            echo "if [[ \$current -lt \$maximum ]]; then /usr/bin/ethtool -G %I rx \$maximum tx \$maximum; fi" >> "/etc/systemd/system/network-optimizer@.service"
        fi
        
        if [[ "$supports_coalesce" == true ]]; then
            echo "echo 'Optimizing interrupt coalescing for %I...'" >> "/etc/systemd/system/network-optimizer@.service"
            echo "/usr/bin/ethtool -C %I adaptive-rx on adaptive-tx on" >> "/etc/systemd/system/network-optimizer@.service"
        fi
        
        # Finish the service file
        echo "echo 'Set interface %I to maximum allowed MTU...'" >> "/etc/systemd/system/network-optimizer@.service"
        echo "current_mtu=\$(/usr/bin/ip -o link show %I | awk '{print \$5}')" >> "/etc/systemd/system/network-optimizer@.service"
        echo "if [[ \$current_mtu -lt 9000 ]]; then" >> "/etc/systemd/system/network-optimizer@.service"
        echo "  for mtu in 9000 4000 1500; do" >> "/etc/systemd/system/network-optimizer@.service"
        echo "    if /usr/bin/ip link set dev %I mtu \$mtu &>/dev/null; then" >> "/etc/systemd/system/network-optimizer@.service"
        echo "      echo \"MTU set to \$mtu\"" >> "/etc/systemd/system/network-optimizer@.service"
        echo "      break" >> "/etc/systemd/system/network-optimizer@.service"
        echo "    fi" >> "/etc/systemd/system/network-optimizer@.service"
        echo "  done" >> "/etc/systemd/system/network-optimizer@.service"
        echo "fi" >> "/etc/systemd/system/network-optimizer@.service"
        
        echo "echo 'Network interface %I optimized'" >> "/etc/systemd/system/network-optimizer@.service"
        echo '"' >> "/etc/systemd/system/network-optimizer@.service"
        
        cat >> "/etc/systemd/system/network-optimizer@.service" << EOF

[Install]
WantedBy=multi-user.target
EOF
        
        # Apply settings now
        echo "Applying optimizations for $interface now..."
        
        if [[ "$supports_features" == true ]]; then
            echo "Enabling TCP/RX/TX offloading..."
            ethtool -K "$interface" tso on gso on gro on rx on tx on
        fi
        
        if [[ "$supports_ring" == true ]]; then
            echo "Optimizing ring buffer..."
            current=$(ethtool -g "$interface" | grep -A 1 'Current hardware settings' | tail -1 | awk '{print $1}')
            maximum=$(ethtool -g "$interface" | grep -A 1 'Pre-set maximums' | tail -1 | awk '{print $1}')
            if [[ $current -lt $maximum ]]; then 
                ethtool -G "$interface" rx "$maximum" tx "$maximum"
            fi
        fi
        
        if [[ "$supports_coalesce" == true ]]; then
            echo "Optimizing interrupt coalescing..."
            ethtool -C "$interface" adaptive-rx on adaptive-tx on
        fi
        
        echo "Testing optimal MTU settings..."
        current_mtu=$(ip -o link show "$interface" | awk '{print $5}')
        if [[ $current_mtu -lt 9000 ]]; then
            for mtu in 9000 4000 1500; do
                if ip link set dev "$interface" mtu "$mtu" &>/dev/null; then
                    echo "MTU set to $mtu"
                    break
                fi
            done
        fi
        
        # Enable the service
        systemctl enable "network-optimizer@$interface.service"
        
        echo -e "${GREEN}Interface $interface optimized. Settings will persist after reboot.${NC}"
    fi
}

# Install and configure irqbalance
optimize_irqbalance() {
    print_header "OPTIMIZING IRQ BALANCING"
    
    if ! command -v irqbalance &> /dev/null; then
        echo "irqbalance is not installed. Installing..."
        pacman -S --needed irqbalance
    fi
    
    echo "Configuring irqbalance for optimal performance..."
    backup_file "/etc/irqbalance.conf"
    
    # Create optimized conf file
    cat > "/etc/irqbalance.conf" << EOF
# Irqbalance configuration options

# Settings for network focused performance
IRQBALANCE_ONESHOT=0
IRQBALANCE_BANNED_CPUS=0
IRQBALANCE_ARGS="--hintpolicy=prefer --policyscript=/etc/irqbalance/irqbalance.sh"
EOF
    
    # Create irqbalance script directory if it doesn't exist
    mkdir -p /etc/irqbalance
    
    # Create IRQ policy script
    cat > "/etc/irqbalance/irqbalance.sh" << 'EOF'
#!/bin/bash

# Get the IRQ number from stdin
read -r IRQ

# Get the device name for this IRQ
DEVICE=$(grep "$IRQ:" /proc/interrupts | awk -F: '{print $2}' | sed 's/^ *//' | cut -d ' ' -f 1)

# Network devices typically have "eth", "wlan", "en", "wl" in their name
if echo "$DEVICE" | grep -qE '(eth|wlan|en|wl|usb)'; then
    # Assign network device IRQs to specific CPUs based on system core count
    CPU_COUNT=$(nproc)
    
    if [ "$CPU_COUNT" -gt 4 ]; then
        # For systems with more than 4 cores, use cores 1-3 (0-indexed)
        echo "balance 2-4"
    elif [ "$CPU_COUNT" -gt 2 ]; then
        # For systems with more than 2 cores, use cores 1-2
        echo "balance 1-2"
    else
        # For dual-core systems, use core 1
        echo "balance 1"
    fi
else
    # Let irqbalance handle other devices automatically
    echo "balance"
fi
EOF
    
    # Make the script executable
    chmod +x /etc/irqbalance/irqbalance.sh
    
    # Enable and start irqbalance service
    systemctl enable irqbalance
    systemctl restart irqbalance
    
    echo -e "${GREEN}IRQ balancing optimized.${NC}"
}

# Install and configure preload for faster application loading
install_preload() {
    print_header "INSTALLING PRELOAD"
    
    if ! pacman -Qs preload > /dev/null; then
        echo "preload is not installed."
        
        if confirm "Would you like to install preload from AUR?" "Y"; then
            # Check if yay is installed
            if ! command -v yay &> /dev/null; then
                if confirm "AUR helper 'yay' is not installed. Would you like to install it?" "Y"; then
                    echo "Installing yay..."
                    pacman -S --needed git base-devel
                    
                    # Create temp directory for building
                    temp_dir=$(mktemp -d)
                    cd "$temp_dir" || exit
                    
                    git clone https://aur.archlinux.org/yay.git
                    cd yay || exit
                    makepkg -si --noconfirm
                    
                    # Cleanup
                    cd / || exit
                    rm -rf "$temp_dir"
                    
                    echo -e "${GREEN}yay installed successfully.${NC}"
                else
                    echo "Skipping preload installation."
                    return
                fi
            fi
            
            echo "Installing preload..."
            sudo -u "$SUDO_USER" yay -S --needed preload
            
            if systemctl is-enabled preload.service &> /dev/null; then
                echo "preload is already enabled."
            else
                systemctl enable preload.service
                systemctl start preload.service
                echo -e "${GREEN}preload enabled and started.${NC}"
            fi
            
            # Configure preload for better performance
            backup_file "/etc/preload.conf"
            
            # Adjust preload configuration
            sed -i 's/^# sortstrategy = 3/sortstrategy = 3/' /etc/preload.conf
            sed -i 's/^# min_cycle = 20/min_cycle = 30/' /etc/preload.conf
            sed -i 's/^# max_cycle = 300/max_cycle = 300/' /etc/preload.conf
            sed -i 's/^# cycle_autotune = true/cycle_autotune = true/' /etc/preload.conf
            
            echo -e "${GREEN}preload installed and configured.${NC}"
        else
            echo "Skipping preload installation."
        fi
    else
        echo "preload is already installed."
        
        if ! systemctl is-enabled preload.service &> /dev/null; then
            if confirm "Enable and start preload service?" "Y"; then
                systemctl enable preload.service
                systemctl start preload.service
                echo -e "${GREEN}preload enabled and started.${NC}"
            fi
        else
            echo -e "${GREEN}preload is already enabled and running.${NC}"
        fi
    fi
}

# Configure browser for faster browsing
optimize_browser() {
    print_header "OPTIMIZING BROWSER SETTINGS"
    
    echo "This will optimize browser settings for Firefox or Chrome/Chromium."
    echo "Note: These changes will affect all users on the system."
    
    if confirm "Would you like to optimize Firefox DNS settings?" "Y"; then
        echo "Configuring Firefox for faster DNS resolution..."
        
        local firefox_policies="/usr/lib/firefox/distribution/policies.json"
        local firefox_dir="/usr/lib/firefox/distribution"
        
        # Create directory if it doesn't exist
        if [[ ! -d "$firefox_dir" ]]; then
            mkdir -p "$firefox_dir"
        fi
        
        backup_file "$firefox_policies"
        
        # Create or update policies.json
        if [[ -f "$firefox_policies" ]]; then
            # Backup current config
            cp "$firefox_policies" "${firefox_policies}.bak.$(date +%Y%m%d)"
            
            # Update existing configuration
            # This is simplified - a more robust approach would use jq or similar tool
            if grep -q '"NetworkPrediction"' "$firefox_policies"; then
                # Policies already has network settings, just inform user
                echo "Firefox policies already contain network settings."
                echo "You may need to manually edit $firefox_policies"
            else
                # Try to add to existing policies
                if grep -q '"policies":' "$firefox_policies"; then
                    # Add to existing policies section
                    sed -i '/"policies": {/ a \
                        "NetworkPrediction": true,\
                        "DNSOverHTTPS": {\
                            "Enabled": true,\
                            "ProviderURL": "https://cloudflare-dns.com/dns-query",\
                            "Locked": false\
                        },\
                        "EnableTrackingProtection": {\
                            "Value": true,\
                            "Locked": false,\
                            "Cryptomining": true,\
                            "Fingerprinting": true\
                        },' "$firefox_policies"
                fi
            fi
        else
            # Create new policies file
            cat > "$firefox_policies" << EOF
{
    "policies": {
        "NetworkPrediction": true,
        "DNSOverHTTPS": {
            "Enabled": true,
            "ProviderURL": "https://cloudflare-dns.com/dns-query",
            "Locked": false
        },
        "EnableTrackingProtection": {
            "Value": true,
            "Locked": false,
            "Cryptomining": true,
            "Fingerprinting": true
        }
    }
}
EOF
        fi
        
        echo -e "${GREEN}Firefox DNS settings optimized.${NC}"
        echo "Note: You may need to restart Firefox for changes to take effect."
    fi
    
    if confirm "Would you like to optimize Chrome/Chromium DNS settings?" "Y"; then
        echo "Configuring Chrome/Chromium for faster DNS resolution..."
        
        local chrome_policy="/etc/opt/chrome/policies/managed/dns_optimization.json"
        local chrome_policy_dir="/etc/opt/chrome/policies/managed"
        local chromium_policy="/etc/chromium/policies/managed/dns_optimization.json"
        local chromium_policy_dir="/etc/chromium/policies/managed"
        
        # Create Chrome policy
        if [[ -d "/etc/opt/chrome" ]] || confirm "Create Chrome policy directory?" "N"; then
            mkdir -p "$chrome_policy_dir"
            backup_file "$chrome_policy"
            
            cat > "$chrome_policy" << EOF
{
    "DnsOverHttpsMode": "automatic",
    "DnsOverHttpsTemplates": "https://cloudflare-dns.com/dns-query{?dns}",
    "PreferredDnsPredictor": "true",
    "PrefetchDNSOnStartup": "true"
}
EOF
            echo -e "${GREEN}Chrome DNS settings optimized.${NC}"
        fi
        
        # Create Chromium policy
        if [[ -d "/etc/chromium" ]] || confirm "Create Chromium policy directory?" "N"; then
            mkdir -p "$chromium_policy_dir"
            backup_file "$chromium_policy"
            
            cat > "$chromium_policy" << EOF
{
    "DnsOverHttpsMode": "automatic",
    "DnsOverHttpsTemplates": "https://cloudflare-dns.com/dns-query{?dns}",
    "PreferredDnsPredictor": "true",
    "PrefetchDNSOnStartup": "true"
}
EOF
            echo -e "${GREEN}Chromium DNS settings optimized.${NC}"
        fi
        
        echo "Note: You may need to restart Chrome/Chromium for changes to take effect."
    fi
}

# Verify current network performance
verify_performance() {
    print_header "VERIFYING NETWORK PERFORMANCE"
    
    echo "Testing current network performance..."
    
    if ! command -v speedtest-cli &> /dev/null; then
        if confirm "speedtest-cli is not installed. Would you like to install it to test network speed?" "Y"; then
            pacman -S --needed python-pip
            pip install speedtest-cli
        else
            echo "Skipping speed test."
            return
        fi
    fi
    
    echo "Running speed test (this may take a minute)..."
    speedtest-cli --simple
    
    if command -v ping &> /dev/null; then
        echo -e "\nTesting latency to Google DNS..."
        ping -c 5 8.8.8.8
    fi
    
    if command -v traceroute &> /dev/null; then
        echo -e "\nTraceroute to Cloudflare DNS (first 5 hops)..."
        traceroute -m 5 1.1.1.1
    fi
    
    # Check if BBR is actually being used
    if [[ -f /proc/sys/net/ipv4/tcp_congestion_control ]]; then
        echo -e "\nCurrent TCP congestion control algorithm:"
        cat /proc/sys/net/ipv4/tcp_congestion_control
    fi
    
    echo -e "\n${GREEN}Performance verification complete.${NC}"
    echo "You can run this script again after changes to compare results."
}

# Main menu
show_menu() {
    clear
    echo -e "${BLUE}======================================================${NC}"
    echo -e "${BLUE}              ARCH LINUX NETWORK OPTIMIZER           ${NC}"
    echo -e "${BLUE}======================================================${NC}"
    echo -e "Select an option:"
    echo -e "1. ${YELLOW}Optimize kernel network parameters${NC} (TCP/BBR)"
    echo -e "2. ${YELLOW}Configure faster DNS servers${NC}"
    echo -e "3. ${YELLOW}Optimize network interface settings${NC}"
    echo -e "4. ${YELLOW}Configure IRQ balancing${NC} (for multi-core systems)"
    echo -e "5. ${YELLOW}Install preload${NC} (faster application loading)"
    echo -e "6. ${YELLOW}Optimize browser settings${NC} (Firefox/Chrome)"
    echo -e "7. ${YELLOW}Verify network performance${NC}"
    echo -e "8. ${GREEN}Perform all optimizations${NC}"
    echo -e "0. ${RED}Exit${NC}"
    
    read -r -p "Enter your choice [0-8]: " choice
    
    case $choice in
        1) optimize_kernel_parameters ;;
        2) optimize_dns ;;
        3) optimize_interface ;;
        4) optimize_irqbalance ;;
        5) install_preload ;;
        6) optimize_browser ;;
        7) verify_performance ;;
        8) 
            optimize_kernel_parameters
            optimize_dns
            optimize_interface
            optimize_irqbalance
            install_preload
            optimize_browser
            verify_performance
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
    esac
    
    read -r -p "Press Enter to return to the menu..."
    show_menu
}

# Show the menu
show_menu 