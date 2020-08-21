#!/bin/bash
#
# Script to install required packages to run the ThousandEyes Monitor Extension on an existing Machine Agent.
# 

set -euo pipefail

# Tell apt-get we're never going to be able to give manual feedback:
export DEBIAN_FRONTEND=noninteractive

apt-get update && \
apt-get install -y curl --no-install-recommends && \
apt-get install -y python3 --no-install-recommends && \
apt-get install -y python3-pip --no-install-recommends && \
apt-get clean && rm -rf /var/lib/apt/lists/* && \
pip3 install requests && \
pip3 install unidecode
