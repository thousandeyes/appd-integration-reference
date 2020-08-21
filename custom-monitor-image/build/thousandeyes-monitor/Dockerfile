#FROM appdynamics/machine-agent-netviz:latest
FROM openjdk:8-jre-slim AS builder

# Analytics Agent listener
EXPOSE 9090

# Install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y unzip --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Machine Agent zip needs to be downloaded from downloads.appdynamics.com
ARG MACHINE_AGENT_ZIP
ARG MACHINE_AGENT_SHA256

# Canonical filenames used in startup script
ENV MA_ZIP MachineAgentBundle.zip
ENV MA_SHA256 MachineAgentBundle.checksum

COPY ${MACHINE_AGENT_ZIP} /${MA_ZIP}
RUN echo "${MACHINE_AGENT_SHA256} *${MA_ZIP}" >> /${MA_SHA256}

# Install AppDynamics Machine Agent
ENV MACHINE_AGENT_HOME /opt/appdynamics/machine-agent
RUN mkdir -p ${MACHINE_AGENT_HOME} && \
    unzip -oq /${MA_ZIP} -d ${MACHINE_AGENT_HOME} && \
    rm /${MA_ZIP}

#Install ThousandEyes Monitor
FROM debian:buster-slim
ENV MACHINE_AGENT_HOME /opt/appdynamics/machine-agent

COPY --from=builder ${MACHINE_AGENT_HOME} ${MACHINE_AGENT_HOME}

COPY startup.sh ${MACHINE_AGENT_HOME}
RUN chmod 744 ${MACHINE_AGENT_HOME}/startup.sh

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates --no-install-recommends && \
 		apt-get install -y wget --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download the ThousandEyes Monitor code
# RUN wget https://github.com/thousandeyes/appd-integration-reference/archive/master.tar.gz && \
# 		tar -xzvf master.tar.gz && \
# 		mv appd-integration-reference-master/custom-monitor/thousandeyes ${MACHINE_AGENT_HOME}/monitors && \
# 		rm -rf appd-integration-reference-master

# If building locally you can copy rather than pulling from GitHub:
COPY thousandeyes ${MACHINE_AGENT_HOME}/monitors/thousandeyes

# Install ThousandEyes Monitor
RUN chmod +x ${MACHINE_AGENT_HOME}/monitors/thousandeyes/install.sh && \
		${MACHINE_AGENT_HOME}/monitors/thousandeyes/install.sh

CMD "${MACHINE_AGENT_HOME}/startup.sh"

