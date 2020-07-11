#!/bin/bash

# A thin helper script for Shapeshifter

GREEN='\033[92m'
BLUE='\033[96m'
YELLOW='\033[93m'
CLEAR='\033[0m'
GREY='\033[90m'

httpsport=8080

# Check for explicitly set values
args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
    if [[ "${args[i]}" == "--port" ]]; then httpsport=${args[i+1]}; fi
done

# -v $(pwd)/sslcert:/opt/shapeshifter/sslcert 000eyes/shapeshifter" 
LOCAL="docker run -p ${httpsport}:8080 -p 4040:4040  --rm --name teappd-agent -it --detach-keys Z -v $(pwd)/.teappd-agent:/teappd-agent 000eyes/teappd-agent"
REMOTE="docker run --rm -it --detach-keys Z -v $(pwd)/.teappd-agent:/teappd-agent 000eyes/teappd-agent"

if [[ "$@" == *"stop"* ]] && [[ "$@" == *"local"* ]] ; then printf "${GREEN}Stopping teappd-agent locally...\n${CLEAR}" && docker stop -t 60 teappd-agent ; # docker exec teappd-agent ./stoplocal.sh && docker stop teappd-agent ; # $LOCAL stop local ;
elif [[ "$@" == *"aws"* ]] ; then $REMOTE $@ ;
elif [[ "$@" == *"status"* ]] ; then curl -k -m 3 -X GET https://localhost:${httpsport} ;
else $LOCAL $@ ;
fi