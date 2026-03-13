# Ubuntu Hunter Probe

Find Ubuntu systems on your local network.

When you're on a LAN or VPN and need to know which machines are running Ubuntu — without logging into each box or combing through DHCP tables manually.

`ubuntu_hunter.sh` combines ARP scanning, Nmap OS fingerprinting, and SSH banner grabbing into a single automated sweep. It auto-detects your subnet, finds live hosts, and filters down to just the Ubuntu ones.

Works on Ubuntu/Debian (`apt`) and RHEL/Fedora/Rocky (`dnf`) hosts.

## Example Output

```
[+] Starting Ubuntu Hunter 9000 (Cross-Distro Edition)...

[+] All required tools are installed.
[+] Local subnet detected: 192.168.1.0/24

[+] Running ARP scan to detect all live hosts on the LAN...
[+] Found 12 live host(s).

[+] Running Nmap OS detection (this takes a moment)...
[+] OS detection complete.

[+] Checking SSH banners for Ubuntu fingerprints...
[+] SSH banner scan done.

[+] Identifying Ubuntu machines...
[+] Ubuntu systems detected:
192.168.1.42
192.168.1.107

[✓] Done! Results saved as:
    live_ips.txt      — all ARP-resolved hosts
    os_scan.txt       — Nmap OS fingerprint results
    ssh_banners.txt   — SSH banner data
    ubuntu_hosts.txt  — clean list of Ubuntu systems
```

## Installation

```bash
git clone https://github.com/tdiprima/ubuntu-hunter-probe.git
cd ubuntu-hunter-probe
chmod +x ubuntu_hunter.sh
```

**Dependencies** — install for your distro:

```bash
# Ubuntu / Debian
sudo apt install nmap arp-scan -y

# RHEL / Fedora / Rocky / AlmaLinux
sudo dnf install nmap arp-scan -y
```

## Usage

```bash
sudo ./ubuntu_hunter.sh
```

Sudo is required for ARP scanning and Nmap OS fingerprinting.

Output files are written to the current directory:

| File                | Contents                              |
|---------------------|---------------------------------------|
| `live_ips.txt`      | All ARP-resolved hosts                |
| `os_scan.txt`       | Nmap OS fingerprint results           |
| `ssh_banners.txt`   | SSH banner data                       |
| `ubuntu_hosts.txt`  | Clean list of detected Ubuntu systems |

## Disclaimer

This tool is intended for use on networks you own or have explicit authorization to scan. Unauthorized network scanning may violate computer fraud laws and organizational security policies. ARP scanning is limited to your local subnet — it will not traverse routers or reach systems you don't have network access to. SSH banner detection can miss Ubuntu hosts if banner hiding is enabled or SSH is firewalled. Use responsibly.

<br>
