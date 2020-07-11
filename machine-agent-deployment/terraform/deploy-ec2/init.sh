#!/bin/sh

# Install Docker on linux mashine
sudo yum install -y docker
sudo service docker start
sudo usermod -aG docker ec2-user

# force get latest image
docker image rm 000eyes/shapeshifter
echo ${DOCKER_RUN}
${DOCKER_RUN}