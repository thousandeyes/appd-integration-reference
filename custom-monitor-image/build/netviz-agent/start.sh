#!/bin/bash

#
# Script to start the AppD Netviz Agent
#

if [ -e "${NETVIZ_HOME}/bin/appd-netagent" ]; then
	
	# Enable Netviz
  sed -i -e "s|enable_netlib = 0|enable_netlib = 1|g" ${NETVIZ_HOME}/conf/agent_config.lua
  sed -i -e "s|WEBSERVICE_IP=.*|WEBSERVICE_IP=\"0.0.0.0\"|g" ${NETVIZ_HOME}/conf/agent_config.lua

  echo "Starting Netviz Agent ${NETVIZ_HOME}/bin/appd-netagent..."
	${NETVIZ_HOME}/bin/appd-netagent -c ./conf -l ./logs -r ./run
else
  echo "AppDynamics Netviz agent not found"
fi

