# openhab-docker
This repository contains scripts and a dockerfile which can be used to create an arm32v7/debian:stretch-slim docker image to run openhab.
The image uses a non-root user in the container (OPENSHIFT ready), a volume to store the persistent openhab configuration, things, items and bindings and exposes the openhab GUI to the host.
This image can be combined with the deCONZ and NODE-RED images to create a quite capable Zigbee Gateway with a powerfull Rule system.
