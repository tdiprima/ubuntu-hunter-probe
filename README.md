# 🕶️ Ubuntu Hunter Probe

**A private LAN-recon toolkit for locating Ubuntu hosts.**  
Why?  Step zero of a hardening campaign: find every Ubuntu host so I can systematically secure them.  
Made for Me. Not for the world. Not for the faint of heart.

## ⚠️ DISCLAIMER — READ BEFORE TOUCHING

This repo is **personal tooling**, built **for my environments only**, and shared here purely for convenience.

If *you* run these scripts:

* I'm not responsible for what happens
* I'm not responsible for your network
* I'm not responsible for your job
* I'm not responsible for the fire you start 🔥
* I'm not responsible for your SOC waking up confused

You break it? That's on you.  
You get blocked? That's on you.  
You summon a demon from a deprecated subnet? Also on you.

Only use on networks you have explicit permission to explore.

## 🐧 What This Does

Ubuntu Hunter Probe is a local-network discovery toolkit that:

* Maps your subnet
* Sniffs out live hosts
* Fingerprints OS types
* Grabs SSH banners
* Extracts Ubuntu machines with receipts
* Outputs clean human-friendly lists
* Works on **RHEL**, **CentOS**, **Rocky**, **AlmaLinux**, and **Ubuntu**

Think of it like sonar for your LAN, but with more attitude.

## 🕳️ **Installation**

### Install dependencies

**RHEL / Rocky / Alma / CentOS**

```bash
sudo dnf install nmap arp-scan -y
```

**Ubuntu / Debian**

```bash
sudo apt install nmap arp-scan -y
```

## 🕵️‍♂️ **Usage**

### RHEL → Scan your local domain

```bash
sudo ./ubuntu_hunter_rhel.sh
```

### Ubuntu → Scan your local domain

```bash
sudo ./ubuntu_hunter_ubuntu.sh
```

### Output files include:

```
live_ips.txt        → All hosts that answered ARP
os_scan.txt         → Nmap OS guesses
ssh_banners.txt     → Banner fingerprints
ubuntu_hosts.txt    → The actual Ubuntu targets
```

If no Ubuntu hosts appear, it means:

* SSH is closed
* Banner hiding is enabled
* The network is stealthy
* Or everything around you is just Windows and sadness

## 🌑 Screenshots / Demo

```
[+] Starting Ubuntu Hunter 9000 (RHEL Edition)...
[+] Detected subnet: 130.x.x.0/24
[+] Found 37 live hosts
[+] Extracting SSH banners...
[+] Ubuntu hosts detected:
    130.x.x.42
    130.x.x.87
```

Imagine this but in your dark terminal theme.
It hits different.

## 🔥 Final Word

This repo is:

* **Mine**
* **For me**
* **For my recon setups**
* **Not a product**
* **Not supported**
* **Not guaranteed not to nuke your LAN**

Use it if you dare.
Or fork it — but I warned you.

<br>
