# 🐧 Ubuntu Hunter Probe

*Find Ubuntu systems lurking on your local network.*

Ubuntu Hunter Probe is a lightweight recon toolkit for identifying Ubuntu-based machines inside your LAN or VPN segment. Designed for security folks, sysadmins, and curious gremlins who want to map their neighborhood quietly and efficiently.

## 🚀 Features

* Auto-detects local subnet (RHEL, Debian, Ubuntu, etc.)
* Uses ARP scanning to find live hosts
* Nmap OS fingerprinting for deeper detection
* SSH banner inspection to confirm Ubuntu versions
* Outputs clean, sortable target lists
* Works on **RHEL**, **CentOS**, **Rocky**, **AlmaLinux**, and **Ubuntu**

## 🧰 Requirements

Make sure these tools are installed:

### On **RHEL / CentOS / Rocky / AlmaLinux**

```bash
sudo dnf install nmap arp-scan -y
```

### On **Ubuntu / Debian**

```bash
sudo apt install nmap arp-scan -y
```

## 📦 Installation

```bash
git clone https://github.com/tdiprima/ubuntu-hunter-probe.git
cd ubuntu-hunter-probe
chmod +x ubuntu_hunter_rhel.sh
chmod +x ubuntu_hunter_ubuntu.sh
```

## 🕵️ Usage

### 🔎 Scan your local network from RHEL/CentOS/etc.

```bash
sudo ./ubuntu_hunter_rhel.sh
```

### 🔎 Scan your local network from Ubuntu/Debian

```bash
sudo ./ubuntu_hunter_ubuntu.sh
```

Both versions:

* Detect your subnet
* Enumerate live hosts
* Attempt OS detection
* Grab SSH banners
* Identify Ubuntu systems
* Save results to:

```
live_ips.txt
os_scan.txt
ssh_banners.txt
ubuntu_hosts.txt
```

## 📁 Output Files

| File               | What It Contains                      |
| ------------------ | ------------------------------------- |
| `live_ips.txt`     | Hosts alive via ARP                   |
| `os_scan.txt`      | Nmap OS detection results             |
| `ssh_banners.txt`  | SSH banner fingerprints               |
| `ubuntu_hosts.txt` | Clean list of detected Ubuntu systems |

## ⚠️ Notes / Reality Checks

* You can only discover machines on **your subnet**, not the whole internet
* SSH banner hiding may result in missed Ubuntu hosts
* Some networks block ARP or suppress OS fingerprinting
* Use responsibly — your SOC loves you until the SIEM alarms start screaming

## 🛠️ Roadmap

* HTML report generator
* OS-family detection (Debian/RHEL/Arch/Windows)
* masscan-assisted fast mode
* MAC vendor parsing
* Stealth scan presets

## 🏷 Tags

`recon • ubuntu • nmap • network-scanning • security-tools`

## 🐻 Author

Bear + ChatGPT  
Master of LAN vibes and subnets that definitely weren't meant to be discovered.

<br>
