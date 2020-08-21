#!/bin/bash
#
# Script to install required packages to run the ThousandEyes Monitor Extension on an existing Machine Agent.
# 
set -euo pipefail

if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
    export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
else
    export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
fi

if [[ $DISTRO == *"centos"* ]]; then
	yum update -y && \
	yum install curl python3 python3-pip vim -y && \
	pip3 install requests && \
	pip3 install unidecode
else
	export DEBIAN_FRONTEND=noninteractive

	apt-get update && \
	apt-get install -y curl --no-install-recommends && \
	apt-get install -y python3 --no-install-recommends && \
	apt-get install -y python3-pip --no-install-recommends && \
	apt-get install -y vim --no-install-recommends && \
	apt-get clean && rm -rf /var/lib/apt/lists/* && \
	pip3 install requests && \
	pip3 install unidecode
fi
