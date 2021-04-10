#!/bin/bash

sudo apt install git -y

mkdir scripts && cd scripts && git clone https://github.com/vulnersCom/nmap-vulners.git && git clone https://github.com/scipag/vulscan

# Note: vulscan database is not working. Potential solution below:
nmap --script nmap-vulners/vulners.nse ,vulscan/vulscan.nse --script-args vulscan/vulscandb=cve.csv -sV 0.0.0.0

# Save the scripts globally
cd /usr/share/nmap/scripts && git clone https://github.com/vulnersCom/nmap-vulners.git
