FROM centos:centos7

EXPOSE 3892

RUN yum update -y && yum install -y \
  net-tools \
  iproute \
  tcpdump \
  curl  \
  unzip   \
  sysvinit-tools \
  openssh-clients


ARG NETVIZ_AGENT_ZIP

ENV NETVIZ_HOME /opt/appdynamics/appd-netviz
COPY ${NETVIZ_AGENT_ZIP} .
RUN mkdir -p ${NETVIZ_HOME} && unzip appd-netviz.zip -d ${NETVIZ_HOME}
WORKDIR ${NETVIZ_HOME}

# Enable netlib
RUN  ./install.sh 

COPY start-netviz.sh .
RUN chmod +x ${NETVIZ_HOME}/start-netviz.sh

CMD "${NETVIZ_HOME}/start-netviz.sh"
