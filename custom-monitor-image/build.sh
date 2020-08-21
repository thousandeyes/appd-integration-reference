#!/bin/bash
if [[ -e "$1" && -ne "build/thousandeyes-monitor/machineagent-bundle.zip" ]]; then
	cp $1 build/thousandeyes-monitor/machineagent-bundle.zip
fi

cp -r ../custom-monitor/thousandeyes ./build/thousandeyes-monitor
docker-compose -f build/thousandeyes-monitor/docker-compose.yaml build --no-cache
