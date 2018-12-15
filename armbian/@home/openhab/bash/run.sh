#$!/bin/bash
#
docker run -d \
	-ti \
	--init \
	--name="openhab" \
	--restart="unless-stopped" \
	--user="9001" \
	--volume="/etc/localtime:/etc/localtime:ro" \
	--volume="/var/lib/services/openhab/:/home/openhab/.openhab/" \
	--network="bridge" \
	-p 8081:8080 \
	-p 8444:8443 \
	-p 9001:9001 \
	-p 9125-9145:9125-9145 \
	-e OPENHAB_HTTP_PORT="8080" \
	-e OPENHAB_HTTPS_PORT="8443" \
	-e OPENHAB_FRONTAIL_PORT="9001" \
	-e OPENHAB_CALLBACK_RANGE="9125-9145" \
	-e OPENHAB_VERSION="$1" \
	openhab:"$1"-arm32v7-debian;

