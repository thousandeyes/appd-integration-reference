#FROM node:buster 
FROM node:12.4.0-alpine

USER root

# Default enviroonment variables. Can be overriden at runtime.
ENV WORKING /opt/shapeshifter
ENV PORT 8080
ENV HTTPPORT 8000
ENV NGROKPORT 4040

ENV USER_TEMPLATES user_templates
ENV TEMPLATES templates

ENV APPDYNAMICS_CONTROLLER_HOST_NAME thousandeyesinc.saas.appdynamics.com
ENV APPDYNAMICS_CONTROLLER_PORT 443
ENV APPDYNAMICS_CONTROLLER_SSL_ENABLED true
ENV APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY 
ENV APPDYNAMICS_AGENT_ACCOUNT_NAME thousandeyesinc
ENV APPDYNAMICS_SIM_ENABLED true

WORKDIR $WORKING

EXPOSE $PORT
EXPOSE $NGROKPORT

RUN mkdir /shapeshifter
RUN mkdir user_templates

RUN apk add bash

#################################################
# Install Terraform
# 
# In addition to running the Shapeshifter API 
# server, the Shapeshifter container also supports
# deploying itself to the cloud using Terraform. 
#
#################################################

RUN apk add curl
RUN apk add jq
RUN set -ex \
  && LATEST_URL=https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip \
  #$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'rc|beta' | egrep 'linux.*amd64' |tail -1)
  && curl ${LATEST_URL} > /tmp/terraform.zip \
  && unzip /tmp/terraform.zip \
  && mv terraform /usr/local/bin/ \
  && echo "Installed: `terraform version`"


# Openssl and SSH support
RUN apk add openssh
RUN apk add openrc
RUN rc-update add sshd
# RUN rc-status

####################
# Install Ngrok
####################

RUN set -ex \
  && apk add --virtual .build-deps wget \
  && apk add ca-certificates \
  \
  && cd /tmp \
  && wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
  && unzip ngrok-stable-linux-amd64.zip \
  && install -v -D ngrok /bin/ngrok \
  && rm -f ngrok-stable-linux-amd64.zip ngrok \
  \
  && apk del .build-deps


###############################
# AppD Machine Agent
###############################
# Downloading directly requires login
# RPM - https://download.appdynamics.com/download/prox/download-file/machine/20.6.0.2676/appdynamics-machine-agent-20.6.0.2676.x86_64.rpm
# Zip - https://download.appdynamics.com/download/prox/download-file/machine-bundle/20.6.0.2676/machineagent-bundle-64bit-linux-20.6.0.2676.zip

#RUN apk add --virtual .build-deps rpm
#RUN apk add rpm

# RUN apt get install rpm
# COPY ./docker/appdynamics-machine-agent-20.6.0.2676.x86_64.rpm ./machine-agent.rpm
# RUN rpm -ivh machine-agent.rpm
# RUN service appdynamics-machine-agent status
RUN apk add openjdk8
RUN apk add python3 && apk add py3-pip && pip3 install --upgrade pip && pip3 install requests
# use non-bundled


#COPY ./docker/machineagent-bundle-64bit-linux-20.6.0.2676.zip ./machine-agent.zip
COPY ./docker/MachineAgent-20.6.0.2676.zip ./machine-agent.zip
RUN mkdir /opt/appdynamics && mkdir /opt/appdynamics/machine-agent 
RUN unzip ./machine-agent.zip -d /opt/appdynamics/machine-agent
# RUN cp /opt/appdynamics/machine-agent/etc/systemd/system/appdynamics-machine-agent.service /etc/systemd/system/appdynamics-machine-agent.service
# RUN systemctl enable appdynamics-machine-agent
# RUN systemctl start appdynamics-machine-agent
# RUN systemctl status appdynamics-machine-agent

#RUN apk del .build-deps


###############################
# ThousandEyes Custom Monitor
###############################
COPY ./machine-agent /opt/appdynamics/machine-agent
RUN chmod +x /opt/appdynamics/machine-agent/monitors/ThousandEyesMonitor/teappd-monitor.py
RUN chmod +x /opt/appdynamics/machine-agent/monitors/ThousandEyesMonitor/teappd-monitor.sh

# Default config location for ngrok
COPY ./docker/ngrok.yml . 

#############################
# Shapeshifter NodeJS Server
#############################
COPY app.js package-lock.json package.json ./

# Core Shapeshifter transform code
COPY ./core core

# Shapeshifter built-in Templates
COPY ./templates templates 

#COPY ./sslcert sslcert
#COPY ./sslcert /etc/ssl/certs

RUN npm install

# Terraform deployment files
COPY ./terraform terraform


COPY ./docker/stoplocal.sh . 
RUN chmod +x stoplocal.sh

COPY ./docker/entrypoint.sh /entrypoint.sh
#COPY ./docker/entrypoint.sh /usr/local/bin/

RUN chmod +x /entrypoint.sh

# Generate cert
RUN mkdir ./sslcert
# RUN openssl req -nodes -new -x509 -subj "/C=US/ST=California/L=SanFrancisco/O=000eyes/CN=000eyes.dev" -keyout ./sslcert/server.key -out ./sslcert/server.cert

RUN java -version

# TODO: use Volume
VOLUME [ "/shapeshifter"] 
#################################################
# Interactive options for running or deploying Shapeshifter
#################################################
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["npm", "start"]