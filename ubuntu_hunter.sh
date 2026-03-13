#!/usr/bin/env bash

# ================================================
#   Ubuntu Hunter 9000 — Cross-Distro Edition
#   Finds Ubuntu boxes on your local network.
#
#   Supports: Ubuntu/Debian (apt) and RHEL/Fedora (dnf)
#   Requires: nmap, arp-scan (must be run as root or via sudo)
#   Produces: live_ips.txt, os_scan.txt, ssh_banners.txt, ubuntu_hosts.txt
# ================================================

set -euo pipefail

# -------- Colors --------
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# ------------------------------------------------------------------
# detect_pkg_manager — determine the distro's package manager
# Returns "apt", "dnf", or "unknown" via stdout
# ------------------------------------------------------------------
detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

# ------------------------------------------------------------------
# check_required_tools — verify nmap and arp-scan are installed;
# print the correct install hint if either is missing
# ------------------------------------------------------------------
check_required_tools() {
    local pkg_manager
    pkg_manager=$(detect_pkg_manager)

    for tool in nmap arp-scan; do
        if ! command -v "${tool}" &>/dev/null; then
            echo -e "${YELLOW}[!] Missing tool: ${tool}${RESET}" >&2
            if [[ "${pkg_manager}" == "unknown" ]]; then
                echo -e "${YELLOW}    Please install '${tool}' using your system's package manager.${RESET}" >&2
            else
                echo -e "${YELLOW}    Install with: sudo ${pkg_manager} install ${tool} -y${RESET}" >&2
            fi
            exit 1
        fi
    done

    echo -e "${GREEN}[+] All required tools are installed.${RESET}"
}

# ------------------------------------------------------------------
# detect_subnet — extract the first globally-scoped IPv4 CIDR from ip
# ------------------------------------------------------------------
detect_subnet() {
    local subnet
    subnet=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n 1)

    if [[ -z "${subnet}" ]]; then
        echo -e "${RED}[✗] Could not detect subnet. Are you connected to a network?${RESET}" >&2
        exit 1
    fi

    echo "${subnet}"
}

# ------------------------------------------------------------------
# scan_arp — discover live hosts on the LAN via ARP broadcast
# ------------------------------------------------------------------
scan_arp() {
    echo "[+] Running ARP scan to detect all live hosts on the LAN..."
    sudo arp-scan --localnet | tee arp_results.txt

    echo ""
    echo "[+] Extracting IP addresses..."
    grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' arp_results.txt | sort -u > live_ips.txt

    if [[ ! -s live_ips.txt ]]; then
        echo -e "${RED}[✗] No hosts detected via ARP. Something is off.${RESET}" >&2
        exit 1
    fi

    echo -e "${GREEN}[+] Found $(wc -l < live_ips.txt) live host(s).${RESET}"
}

# ------------------------------------------------------------------
# scan_os — run Nmap OS fingerprinting against discovered hosts
# ------------------------------------------------------------------
scan_os() {
    echo "[+] Running Nmap OS detection (this takes a moment)..."
    sudo nmap -O -iL live_ips.txt -oN os_scan.txt > /dev/null
    echo -e "${GREEN}[+] OS detection complete.${RESET}"
}

# ------------------------------------------------------------------
# scan_ssh_banners — grab SSH banners to fingerprint Ubuntu systems
# ------------------------------------------------------------------
scan_ssh_banners() {
    echo "[+] Checking SSH banners for Ubuntu fingerprints..."
    sudo nmap -p22 --script banner -iL live_ips.txt -oN ssh_banners.txt > /dev/null
    echo -e "${GREEN}[+] SSH banner scan done.${RESET}"
}

# ------------------------------------------------------------------
# extract_ubuntu_hosts — filter banner results for Ubuntu indicators
# ------------------------------------------------------------------
extract_ubuntu_hosts() {
    echo "[+] Identifying Ubuntu machines..."
    grep -i "Ubuntu" -B2 -A5 ssh_banners.txt > ubuntu_hosts_raw.txt || true
    grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ubuntu_hosts_raw.txt | sort -u > ubuntu_hosts.txt || true

    if [[ ! -s ubuntu_hosts.txt ]]; then
        echo -e "${YELLOW}[!] No Ubuntu hosts found.${RESET}"
        echo -e "${YELLOW}    Possible reasons:${RESET}"
        echo -e "${YELLOW}      - SSH is disabled on target hosts${RESET}"
        echo -e "${YELLOW}      - Banner hiding is enabled${RESET}"
        echo -e "${YELLOW}      - Hosts are behind firewalls${RESET}"
    else
        echo -e "${GREEN}[+] Ubuntu systems detected:${RESET}"
        cat ubuntu_hosts.txt
    fi
}

# ------------------------------------------------------------------
# print_summary — report output file locations
# ------------------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${GREEN}[✓] Done! Results saved as:${RESET}"
    echo "    live_ips.txt      — all ARP-resolved hosts"
    echo "    os_scan.txt       — Nmap OS fingerprint results"
    echo "    ssh_banners.txt   — SSH banner data"
    echo "    ubuntu_hosts.txt  — clean list of Ubuntu systems"
}

# ------------------------------------------------------------------
# main — orchestrate all steps
# ------------------------------------------------------------------
main() {
    echo -e "${GREEN}[+] Starting Ubuntu Hunter 9000 (Cross-Distro Edition)...${RESET}"
    echo ""

    check_required_tools
    echo ""

    local subnet
    subnet=$(detect_subnet)
    echo -e "${GREEN}[+] Local subnet detected: ${subnet}${RESET}"
    echo ""

    scan_arp
    echo ""

    scan_os
    echo ""

    scan_ssh_banners
    echo ""

    extract_ubuntu_hosts

    print_summary
    echo ""
    echo -e "${GREEN}[✓] Ubuntu Hunter 9000 complete.${RESET}"
}

main "$@"
