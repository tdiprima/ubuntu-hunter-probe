#!/bin/bash

# ================================================
#   Ubuntu Hunter 9000 — RHEL Edition
#   "Find Ubuntu boxes on MY local network"
# ================================================

# -------- Colors (for vibes) --------
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}[+] Starting Ubuntu Hunter 9000 (RHEL Edition)...${RESET}"
echo ""

# ==================================================
# Step 0 — Check that required tools exist
# ==================================================

for tool in nmap arp-scan; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${YELLOW}[!] Missing tool: $tool${RESET}"

        if [[ "$tool" == "arp-scan" ]]; then
            echo -e "${YELLOW}    Install with: sudo dnf install arp-scan -y${RESET}"
        else
            echo -e "${YELLOW}    Install with: sudo dnf install nmap -y${RESET}"
        fi

        exit 1
    fi
done

echo -e "${GREEN}[+] All required tools are installed!${RESET}"
echo ""

# ==================================================
# Step 1 — Detect local subnet (RHEL-safe)
# ==================================================

echo "[+] Detecting your local subnet..."

# Explanation:
# ip -o addr show → one-line output for all interfaces
# awk: find IPv4 "scope global" addresses and extract the CIDR notation (x.x.x.x/xx)
SUBNET=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n 1)

if [ -z "$SUBNET" ]; then
    echo -e "${RED}[✗] Could not detect subnet. Are you connected to a network?${RESET}"
    exit 1
fi

echo -e "${GREEN}[+] Local subnet detected: $SUBNET${RESET}"
echo ""

# ==================================================
# Step 2 — ARP scan for live hosts
# ==================================================

echo "[+] Running ARP scan to detect all hosts on your LAN..."
sudo arp-scan --localnet | tee arp_results.txt

echo ""
echo "[+] Extracting IP addresses..."
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' arp_results.txt | sort -u > live_ips.txt

if [ ! -s live_ips.txt ]; then
    echo -e "${RED}[✗] No hosts detected via ARP. Something is off.${RESET}"
    exit 1
fi

echo -e "${GREEN}[+] Found $(wc -l < live_ips.txt) live hosts.${RESET}"
echo ""

# ==================================================
# Step 3 — Nmap OS Detection
# ==================================================

echo "[+] Running Nmap OS detection (this takes a moment)..."
sudo nmap -O -iL live_ips.txt -oN os_scan.txt > /dev/null

echo -e "${GREEN}[+] OS detection complete.${RESET}"
echo ""

# ==================================================
# Step 4 — SSH Banner Grab (Ubuntu fingerprints)
# ==================================================

echo "[+] Checking SSH banners for Ubuntu clues..."
sudo nmap -p22 --script banner -iL live_ips.txt -oN ssh_banners.txt > /dev/null

echo -e "${GREEN}[+] SSH banner scan done.${RESET}"
echo ""

# ==================================================
# Step 5 — Extract Ubuntu Hosts
# ==================================================

echo "[+] Identifying Ubuntu machines..."

# Find any section that mentions Ubuntu
grep -i "Ubuntu" -B2 -A5 ssh_banners.txt > ubuntu_hosts_raw.txt

# Extract only clean IPs
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ubuntu_hosts_raw.txt | sort -u > ubuntu_hosts.txt

echo ""

if [ ! -s ubuntu_hosts.txt ]; then
    echo -e "${YELLOW}[!] No Ubuntu hosts found.${RESET}"
    echo -e "${YELLOW}    Reasons might be:${RESET}"
    echo -e "${YELLOW}      - SSH disabled${RESET}"
    echo -e "${YELLOW}      - Banner hiding enabled${RESET}"
    echo -e "${YELLOW}      - Machines behind firewalls${RESET}"
else
    echo -e "${GREEN}[+] Ubuntu systems detected:${RESET}"
    cat ubuntu_hosts.txt
fi

echo ""
echo -e "${GREEN}[✓] Done! Results saved as:${RESET}"
echo "    live_ips.txt"
echo "    os_scan.txt"
echo "    ssh_banners.txt"
echo "    ubuntu_hosts.txt"
echo ""
echo -e "${GREEN}[✓] Ubuntu Hunter 9000 — RHEL Edition complete.${RESET}"
