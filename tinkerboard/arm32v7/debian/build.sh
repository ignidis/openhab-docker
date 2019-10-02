#!/bin/bash
#
# docker build openhab image
# Usage:
#        [sudo] build.sh <openhab-version> <java-zulu-embedded-url> <nodejs-version>
#
# Must run as superuser, either you are root or must sudo 
#
# Zulu 8 for ARMV32 with HARD FLOATING POINT
# JAVA_URL="https://cdn.azul.com/zulu-embedded/bin/zulu8.40.0.178-ca-jdk1.8.0_222-linux_aarch32hf.tar.gz"
#
docker build --build-arg OPENHAB_VERSION="$1" --build-arg JAVA_URL="$2" --build-arg NODE_VERSION="$3" --build-arg OPENHAB_SVC_NAME="openhab" --build-arg OPENHAB_SVC_UID="9001" -t openhab:"$1"-arm32v7-debian .
