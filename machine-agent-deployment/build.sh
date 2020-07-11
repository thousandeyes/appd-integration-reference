#!/bin/bash
docker build -t 000eyes/teappd-agent .
docker image inspect 000eyes/teappd-agent | grep Size
docker image inspect 000eyes/teappd-agent | grep 000eyes/teappd-agent
if [ "$1" == "-p" ] ; then
	docker push 000eyes/teappd-agent
fi