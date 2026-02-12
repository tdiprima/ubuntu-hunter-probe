#!/bin/bash

# ==============================
#  Ubuntu Hunter 9000™
#  "Find all Ubuntu boxes near me"
# ==============================

# -------- Colors (for vibes) --------
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}[+] Starting Ubuntu Hunter 9000...${RESET}"
echo ""

# Safety first — bail if nmap or arp-scan aren't installed
for tool in nmap arp-scan; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${YELLOW}[!] Missing tool: $tool${RESET}"
        echo "    Install it first: sudo apt install $tool"
        exit 1
    fi
done

echo -e "${GREEN}[+] All required tools are installed!${RESET}"
echo ""

echo "[+] Detecting your local network range..."
# This grabs your active network interface and extracts the subnet (e.g., 192.168.1.0/24)
SUBNET=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n 1)

if [ -z "$SUBNET" ]; then
    echo -e "${RED}[✗] Could not detect subnet. Are you connected to a network?${RESET}"
    exit 1
fi

echo -e "${GREEN}[+] Using subnet: $SUBNET${RESET}"
echo ""

# -------------------------
# Step 1: Find all hosts on LAN using ARP
# -------------------------
echo "[+] Running ARP scan to find all live hosts on the LAN..."
sudo arp-scan --localnet | tee arp_results.txt

echo ""
echo "[+] Extracting IPs from ARP results..."
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' arp_results.txt > live_ips.txt

if [ ! -s live_ips.txt ]; then
    echo "[✗] No hosts detected via ARP."
    exit 1
fi

echo -e "${GREEN}[+] Found $(wc -l < live_ips.txt) live hosts.${RESET}"
echo ""

# -------------------------
# Step 2: Run Nmap OS detection
# -------------------------
echo "[+] Running Nmap OS detection (this may take a bit)..."
sudo nmap -O -iL live_ips.txt -oN os_scan.txt > /dev/null

echo -e "${GREEN}[+] OS detection complete.${RESET}"
echo ""

# -------------------------
# Step 3: Detect Ubuntu via SSH banners
# -------------------------
echo "[+] Checking SSH banners for Ubuntu fingerprints..."
sudo nmap -p22 --script banner -iL live_ips.txt -oN ssh_banners.txt > /dev/null

echo -e "${GREEN}[+] SSH banner scan done.${RESET}"
echo ""

# -------------------------
# Step 4: Filter results for Ubuntu systems
# -------------------------

echo "[+] Identifying Ubuntu hosts..."

# Look for "Ubuntu" or OpenSSH versions known to be Ubuntu-specific
grep -i "Ubuntu" -B2 -A5 ssh_banners.txt > ubuntu_hosts_raw.txt

# Extract only the clean IP list
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ubuntu_hosts_raw.txt | sort -u > ubuntu_hosts.txt

if [ ! -s ubuntu_hosts.txt ]; then
    echo -e "${YELLOW}[!] No Ubuntu hosts detected. They might not expose SSH or banner hiding is enabled.${RESET}"
else
    echo -e "${GREEN}[+] Found Ubuntu hosts:${RESET}"
    cat ubuntu_hosts.txt
fi

echo ""
echo -e "${GREEN}[+] Done! All results saved:${RESET}"
echo "    - live_ips.txt        (all ARP-resolved hosts)"
echo "    - os_scan.txt         (Nmap OS guesses)"
echo "    - ssh_banners.txt     (SSH banner data)"
echo "    - ubuntu_hosts.txt    (clean list of Ubuntu systems)"
echo ""
echo -e "${GREEN}[✓] Ubuntu Hunter 9000 complete.${RESET}"
