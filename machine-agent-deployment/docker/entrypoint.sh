#!/usr/bin/env bash

GREEN='\033[92m'
BLUE='\033[96m'
YELLOW='\033[93m'
GREY='\033[37m'
CLEAR='\033[90m'

command=$1
target=$2

shared=/shapeshifter
aws_credentials=/shapeshifter/credentials
ngroktoken=1cYdObbmkNMS8tcs4WwK71i8yHq_3q2L18VXyofmSKurvWfT
aws_root_cred=/root/.aws/credentials
working=$WORKING
appdworking=/opt/appdynamics/machine-agent

port=$PORT
portset=""
ngrokport=$NGROKPORT
hostname=""
workspace=""
createtunnel=yes
verbose=false
certonly=no

#docker_run="docker run -p $port:8080 -p 4040:4040 --name teappd-agent -d 000eyes/teappd-agent deploy nongrok --port $port"
TFINIT="terraform init -no-color"
TFAPPLY="terraform apply -no-color"
TFDESTROY="terraform destroy -no-color"


# Should be set in env variable to IAM User on 000eyes AWS with limited Route53 account access that can only edit 000eyes.dev records.
aws_access_key=$ROUTE53_ACCESS_KEY
aws_secret_key=$ROUTE53_SECRET_KEY


printf "${CLEAR}"
# Add interactive option "-i"

# TODO: Use remote Terraform state file (000eyes hosted S3) to manage both local and cloud state. 

output () {
	if [[ "$verbose" == "true" ]]; then
		"$@"
	else
		"$@" > /dev/null
	fi
}

launch () {
	if [[ "$verbose" == "true" ]]; then
		"$@" &
	else
		"$@" > /dev/null &
	fi
  pids+="$!" # Add pid for sigterm handling
}

echo_docker_run () {
	port=$1
	echo "docker run -p $port:8080 -p 4040:4040 --rm --name teappd-agent -d 000eyes/teappd-agent deploy local --notunnel --host $hostname --port $port"
}

get_port () {
	if [[ ! portset ]]; then
	  if test -f "$shared/port"; then
	  	port=$(cat $shared/port)
		else
			printf "${BLUE}What port would you like the Machine Agent to run on? ${YELLOW}" 
	    read port
	  fi
	fi

  echo $port > $shared/port
}

# Get user AWS credentials
get_aws_credentials () {
	if [ ! -d "/root/.aws" ]; then
  	mkdir /root/.aws
	fi

	if test -f "$aws_credentials"; then
  	#printf "\n${BLUE}Using shared AWS credentials file (${GREEN}/shapeshifter/credentials${BLUE})${CLEAR}" 
  	cp $aws_credentials $aws_root_cred
	else
  	#printf "No shared AWS credentials file found.\n" 
		printf "${BLUE}What is your AWS Access Key ID? ${YELLOW}" 
    read accesskey
    printf "${BLUE}What is your AWS Secret Key? ${YELLOW}" 
    read secretkey
    printf "${CLEAR}"
    if [[ "$accesskey" != "" && "$secretkey" != "" ]]; then
    	printf "[default]\naws_access_key_id = $accesskey\naws_secret_access_key = $secretkey\n" > $aws_root_cred
    	cp $aws_root_cred $aws_credentials
    fi
	fi
}

tf_deploy_aws () {
  get_aws_credentials
  cd $working/terraform/deploy-ec2
	output terraform init -no-color
	docker_run=$(echo_docker_run $port) 
  output terraform apply -auto-approve -no-color -var="httpsport=$port" -var="docker-run=$docker_run" -var="hostname=$hostname"

	keypair=$(tfout keypair)
  cp $keypair $shared/
}

tf_deploy_hostname () {
	host=$1
	targeturl=$2
  target_fqdn=${targeturl#"https://"}
  cd $working/terraform/deploy-hostname
  output terraform init -no-color
  output terraform apply -no-color -auto-approve -var="hostname=$hostname" -var="ip=$target_fqdn"
}

tf_deploy_cname () {
	host=$1
	targeturl=$2
  target_fqdn=${targeturl#"https://"}
  cd $working/terraform/deploy-cname
  output terraform init -no-color
  output terraform apply -no-color -auto-approve -var="hostname=$hostname" -var="ip=$target_fqdn"
}

tf_deploy_cert () {
	host=$1
  get_aws_credentials
  cd $working/terraform/deploy-cert
  output terraform init -no-color
  output terraform apply -no-color -auto-approve -var="hostname=$host" 
  mkdir $shared/sslcert/
	cp $(tfout certpath) $working/sslcert/
	cp $(tfout certkeypath) $working/sslcert/
	cp $(tfout certpath) $shared/sslcert/
	cp $(tfout certkeypath) $shared/sslcert/
}

tf_stop_remote () {
  get_aws_credentials
  cd $working/terraform/deploy-ec2
	output terraform init -no-color
	output terraform destroy -no-color -auto-approve

  get_aws_credentials
  cd $working/terraform/deploy-hostname
	output terraform init -no-color
	output terraform destroy -no-color -auto-approve
}

tf_stop_local () {
  cd $working/terraform/deploy-hostname
	output terraform init -no-color 
  output terraform destroy -no-color -auto-approve 

  cd $working/terraform/deploy-cert
	output terraform init -no-color 
  output terraform destroy -no-color -auto-approve 
}

tfout () {
	outvar=$1
  local retval=$(terraform output $outvar)
  echo "$retval"
}

clear_shared () {
	hostname=""
	url=""
	port=""
	echo "" > $shared/url
  echo "" > $shared/host
  echo "" > $shared/port
}

pids=()
cleanup () {
	printf "${GREEN}Stopping AppD Integration Machine Agent...\n${CLEAR}"
	if [[ "$target" == "local" && "$hostname" != "" ]] ; then
	  printf "${GREEN}Removing ${BLUE}$hostname.000eyes.dev${GREEN} DNS entry...\n${CLEAR}"
		tf_stop_local
	fi
	clear_shared 
	for pid in "${pids[@]}"
	do
		kill -SIGTERM "$pid"
    wait "$pid"
	done

  exit 0; # 128 + 15 -- SIGTERM
}

# Kill the last background process, which is `tail -f /dev/null` and execute the specified handler
# Consider using Tini as the init handler as it manages signal proocessing - https://github.com/krallin/tini
trap 'kill ${!}; cleanup' SIGTERM
trap 'kill ${!}; cleanup' SIGINT

# Check for explicitly set values
args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
    if [[ "${args[i]}" == "--port" ]]; then port=${args[i+1]} && portset="true"; fi
    if [[ "${args[i]}" == "--host" ]]; then hostname=${args[i+1]}; fi
    if [[ "${args[i]}" == "--certonly" ]]; then hostname=${args[i+1]} && certonly=true; fi
    if [[ "${args[i]}" == "--verbose" ]]; then set -x; verbose=true; fi
    if [[ "${args[i]}" == "--notunnel" ]]; then createtunnel=no; fi
done

publicip=$(curl -s http://whatismyip.akamai.com/)
if [[ "$publicip" == "" ]]; then
	printf "${YELLOW}AppD Integration Machine Agent must be able to connect to the internet. Stopping.${CLEAR}\n"
	exit 0
fi

if [ ! -d "$shared" ]; then
	mkdir $shared
fi

if [ "$command" == "" ] ; then
	printf "${GREEN}AppD Integration Machine Agent Deployment\n${CLEAR}"
	printf "${BLUE}Enter a command: (${GREEN}deploy${BLUE} | ${GREEN}stop${BLUE} | ${GREEN}status${BLUE} ): ${YELLOW}"
	read command || command="deploy"
	printf "${BLUE}Deploy to: (${GREEN}local${BLUE} | ${GREEN}aws${BLUE}): ${YELLOW}"
	read target || target="local"
	if [[ "$target" == "local" ]]; then 
		printf "${BLUE}Configure reverse proxy (public IP)? (${GREEN}no${BLUE}): ${YELLOW}"
		read createtunnel || createtunnel=no
	fi
	if [[ "$command" == "deploy" ]]; then 
		printf "${BLUE}000eyes.dev hostame: (${GREEN}<none>${BLUE}): ${YELLOW}"
		read hostname || hostname=""


		printf "${BLUE}AppD Host Name: (${GREEN}$APPDYNAMICS_CONTROLLER_HOST_NAME{BLUE}): ${YELLOW}"
		read appd_hostname || appd_hostname="$APPDYNAMICS_CONTROLLER_HOST_NAME"

		printf "${BLUE}AppD Key: (${GREEN}$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY${BLUE}): ${YELLOW}"
		read appd_key || appd_key="$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"

		printf "${BLUE}AppD Account Name: (${GREEN}$APPDYNAMICS_AGENT_ACCOUNT_NAME${BLUE}): ${YELLOW}"
		read appd_accountname || appd_accountname="$APPDYNAMICS_AGENT_ACCOUNT_NAME"

		export APPDYNAMICS_CONTROLLER_HOST_NAME=$appd_hostname
		export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=$appd_key
		export APPDYNAMICS_AGENT_ACCOUNT_NAME=$appd_accountname
	fi

  printf "${CLEAR}"
fi

if [ "$command" == "connect" ] ; then
	exec /bin/bash
fi


#################################################
# Copy Certs
#################################################
if [[ "$command" == "deploy" ]] ; then # && test -f "$shared/sslcert/server.key" && test -f "$shared/sslcert/server.cert" ]] ; then
	mkdir $working/sslcert &>/dev/null
	cp -r $shared/sslcert $working/sslcert &>/dev/null
fi

#################################################
# Local Deploy
#################################################
if [[ "$command" == "deploy" ]] && [[ "$target" == "local" ]]; then
  printf "${GREEN}Deploying AppD Integration Machine Agent locally...\n${CLEAR}"
  
	#################################################
	# Start NGrok Reverse Proxy
	#################################################
	if [[ "$createtunnel" == "yes" ]] ; then
    cd $working
		output ngrok authtoken $ngroktoken
		output ngrok start -config $working/ngrok.yml -config /root/.ngrok2/ngrok.yml --log=stdout shapeshifter &
		pids+="$!" # Add ngrok pid
		
		# Wait for tunnel to come online and get tunnel URL
    tunnel_url=""
		until [[ -n "$tunnel_url" && ! -z "$tunnel_url" ]] ; do
			sleep 2
			tunnel_url=$(curl --silent http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')
		done
		printf "${CLEAR}"
	fi

	#################################################
	# Deploy DNS Entry (Route53 - Terraform)
	#################################################
	if [[ "$hostname" ]] ; then #&& [[ "$tunnel_url" ]] ; then 
	  printf "${GREEN}Provisioning ${BLUE}$hostname.000eyes.dev${GREEN} DNS entry (this may take a few minutes)...\n${CLEAR}"
		echo $hostname > $shared/host
		if [[ ! -n "$tunnel_url" ]]; then 
			tunnel_url="https://$(curl -s http://whatismyip.akamai.com/)" 
			tf_deploy_hostname $hostname $tunnel_url
	  else
		#if [[ "$certonly" != "yes" ]]; then
			tf_deploy_cname $hostname $tunnel_url
    fi
    if [[ ! -e "$working/sslcert/server.key" || ! -e "$working/sslcert/server.cert" ]] ; then
	    printf "${GREEN}Provisioning SSL certificate for ${BLUE}$hostname.000eyes.dev${GREEN}...\n${CLEAR}"
	    tf_deploy_cert $hostname
		else printf "${CLEAR}SSL certs already exist; Skipping cert creation.\n"; 
		fi
	fi

	#################################################
	# Start AppD Machine Agent Service
	#################################################
  # Set AppD Machine Agent name
	if [[ -n "$hostname" ]]; then export APPDYNAMICS_AGENT_UNIQUE_HOST_ID="teappd-$hostname"; else export APPDYNAMICS_AGENT_UNIQUE_HOST_ID="teappd-$publicip"; fi
  printf "${GREEN}Starting AppD Integration Machine Agent ${BLUE}APPDYNAMICS_AGENT_UNIQUE_HOST_ID${GREEN}...${CLEAR}\n"
	cd $appdworking
	launch ./bin/machine-agent

	#################################################
	# Start Shapeshifter Server (nodejs)
	#################################################
  cd $working
  output npm start &
  pids+="$!" # Add npm pid
	sleep 3

	echo $port > $shared/port
	echo "https://localhost:${port}" > $shared/url

  printf "${GREEN}Alerts webhook available at:${CLEAR}\n"
	if [[ "$tunnel_url" != "" ]]; then printf " - ${YELLOW}$tunnel_url${CLEAR}\n"; fi
	if [[ "$hostname" ]] && [[ "$tunnel_url" ]]; then printf " - ${YELLOW}https://$hostname.000eyes.dev${CLEAR}\n"; fi
	printf " - ${YELLOW}https://localhost:$port${CLEAR}\n"
	printf "\nPress ${BLUE}'Z'${CLEAR} to detach and keep Integration Agent running. Press ${BLUE}'Ctrl+c'${CLEAR} to stop Shapeshifter.${CLEAR}\n"



elif [[ "$command" == "deploy" ]] && [[ "$target" == "aws" ]] ; then
	get_port
	printf "${GREEN}Deploying Integration Agent to AWS on port ${YELLOW}$port${GREEN} (this may take a few minutes)...\n${CLEAR}"
  tf_deploy_aws
  fqdn=$(tfout public_url_domain)
  url=$(tfout public_url)
	#tf_deploy_cert $hostname

	echo $url > $shared/url

  printf "${GREEN}Alerts webhook available at:${CLEAR}\n"
	if [[ "$url" != "" ]]; then printf " - ${YELLOW}$url${CLEAR}\n"; fi
	if [[ "$fqdn" != "" ]]; then printf " - ${YELLOW}$fqdn${CLEAR}\n"; fi

elif [[ "$command" == "stop" ]] ; then #&& [[ "$target" == "aws" ]] ; then
	printf "${GREEN}Shutting down Integration Agent on $target...\n${CLEAR}"
	tf_stop_remote
  clear_shared
  printf "${GREEN}Integration Agent has been terminated on $target.${CLEAR}\n"


elif [[ "$command" == "ssh" ]] && [[ "$target" == "aws" ]] ; then
  cd $working/terraform/deploy-ec2
  output terraform init -no-color 
  keypairname=$(tfout keypairname)
  ip=$(tfout publicip)
  user=$(tfout user)
  ssh="ssh -i $shared/$keypair $user@$ip" 
  echo $ssh
  exec $ssh

elif [[ "$command" == "status" ]] ; then
	url=$(cat $shared/url)
	if [[ "$url" != "" ]]; then
		printf "${GREEN}Querying Integration Agent at ${BLUE}$url${GREEN}...\n${CLEAR}"
		curl -k -m 3 -X GET $url
	else
		printf "${GREEN}Integration Agent does not appear to be deployed\n${CLEAR}"
	fi

elif [ "$command" == "help" ] ; then
	printf "\n${GREEN}Shapeshifter usage:\n${CLEAR}"
	printf "\n${BLUE}Deploy and run on AWS:${CLEAR}"
	printf "\n${CLEAR} > docker run -p 8080:8080 -p 4040:4040 --rm --name shapeshifter -it -v \$(pwd)/.shapeshifter:/shapeshifter 000eyes/shapeshifter deploy aws${CLEAR}"
	printf "\n${BLUE}Run locally:${CLEAR}"
	printf "\n${CLEAR} > docker run -p 8080:8080 -p 4040:4040 --rm --name shapeshifter -it -v \$(pwd)/.shapeshifter:/shapeshifter 000eyes/shapeshifter deploy local${CLEAR}"
	printf "\n\n"
fi


# Keep container running...
while true
do
  tail -f /dev/null & wait ${!}
done
