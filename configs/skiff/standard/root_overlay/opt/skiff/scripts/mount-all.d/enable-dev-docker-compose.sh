#!/bin/sh

echo "Enabling tcp docker daemon allow to deploy docker container with docker-compose, be sure to understand security risks"
echo "See https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-socket-option"
echo "You may customize host and port by setting DOCKER_TCP_HOST & DOCKER_TCP_PORT env variables prior running this script"

DOCKER_CONFD=/etc/systemd/system/docker.service.d
DOCKER_SERVICE=${DOCKER_CONFD}/execstart.conf

# Grab the current docker execstart
if [ -f "$DOCKER_SERVICE" ]; then
  DOCKER_EXECSTART=$(cat $DOCKER_SERVICE | grep '^ExecStart=..*$' | sed -e 's/ExecStart=//')
fi

if [ ! -z "$DOCKER_EXECSTART" ]; then
  LOCAL_NETWORK_IP=$(ifconfig | grep addr:192.168 | cut -d':' -f2 | cut -d' ' -f1)
  DOCKER_EXECSTART+=" -H=${DOCKER_TCP_HOST:-$LOCAL_NETWORK_IP}:${DOCKER_TCP_PORT:-2375}"
  echo "Configuring Docker to start with '$DOCKER_EXECSTART'"
  printf "[Service]\nExecStart=\nExecStart=$DOCKER_EXECSTART" > $DOCKER_SERVICE
fi

systemctl daemon-reload
systemctl restart docker
