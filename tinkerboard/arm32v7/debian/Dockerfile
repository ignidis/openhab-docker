FROM arm32v7/debian:stretch-slim

#
# Build Time Arguments
#
ARG OPENHAB_VERSION
ARG JAVA_URL
ARG NODE_VERSION
ARG	OPENHAB_SVC_NAME
ARG	OPENHAB_SVC_UID

#
# Runtime environment variables
#
ENV	EXTRA_JAVA_OPTS="" \
	OPENHAB_HTTP_PORT="8080" \
	OPENHAB_HTTPS_PORT="8443" \
	OPENHAB_FRONTTAIL_PORT="9001" \
	OPENHAB_LSP_PORT="5007" \
	PATH="/opt/node/bin:${PATH}"

# Update the operating system and install required packges
#
RUN	export DEBIAN_FRONTEND="noninteractive"; \
	export TERM="xterm"; \
	apt-get update; \
	apt-get install -y --no-install-recommends --autoremove apt-utils xz-utils unzip wget ca-certificates; \
	apt-get install -y --no-install-recommends --autoremove \
	sudo \
	; \
#
# Define Service Account variables
#
	SERVICE_USER=${OPENHAB_SVC_NAME}; \
	SERVICE_USER_UID=${OPENHAB_SVC_UID}; \
	SERVICE_GROUP=${OPENHAB_SVC_NAME}; \
	SERVICE_GROUP_UID=${OPENHAB_SVC_UID}; \
#
# Do not add sudo, if required add that group to the docker run command
#
	ADD_GROUPS=""; \
#
# Create service group and service account
#
	groupadd -g "$SERVICE_GROUP_UID" "$SERVICE_GROUP"; \
	useradd -u "$SERVICE_USER_UID" -g "$SERVICE_GROUP" --groups "$ADD_GROUPS" --shell /bin/bash --create-home "$SERVICE_USER"; \
#
# Allow service account to sudo without pasword
# We will use this only when we need a initialization run for the container, the init run should also assign the sudo group to the service user
#
#	echo "${SERVICE_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/090_${SERVICE_USER}-nopasswd; \
#
# CWD
#
	cd /home/"$SERVICE_USER"/; \
#
# Install the Java Runtime
#
	JAVA_HOME='/usr/lib/java'; \
	wget -nv -O /tmp/java.tar.gz ${JAVA_URL}; \
	mkdir ${JAVA_HOME}; \
	tar --exclude='man' --exclude='demo' --exclude='sample' --exclude='src.zip' -xvf /tmp/java.tar.gz --strip-components=1 -C ${JAVA_HOME}; \
	rm /tmp/java.tar.gz; \
	update-alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 50; \
	update-alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 50; \
#
# Install Java unlimited strength cryptography
#
  	wget -q -O /tmp/ZuluJCEPolicies.zip https://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip; \
  	unzip -jo -d ${JAVA_HOME}/jre/lib/security /tmp/ZuluJCEPolicies.zip; \
  	rm /tmp/ZuluJCEPolicies.zip; \
#
# Install openhab
#
	OPENHAB_URL="https://bintray.com/openhab/mvn/download_file?file_path=org/openhab/distro/openhab/${OPENHAB_VERSION}/openhab-${OPENHAB_VERSION}.zip"; \
	wget -nv -O /tmp/openhab.zip ${OPENHAB_URL}; \
	unzip -q /tmp/openhab.zip -d /opt/openhab/; \
	rm /tmp/openhab.zip; \
	mv /opt/openhab/userdata /opt/openhab/userdata.dist; \
	mv /opt/openhab/conf /opt/openhab/conf.dist; \
	mv /opt/openhab/addons /opt/openhab/addons.dist; \
	echo "export TERM=dumb" | tee -a ~/.bashrc; \
#
# Install the nodeJS Runtime
#
	ARCH= \ 
	    dpkgArch="$(dpkg --print-architecture)"; \
	    case "${dpkgArch##*-}" in \
		amd64) ARCH='x64';; \
		ppc64el) ARCH='ppc64le';; \
		s390x) ARCH='s390x';; \
		arm64) ARCH='arm64';; \
		armhf) ARCH='armv7l';; \
		i386) ARCH='x86';; \
		*) echo "unsupported architecture"; exit 1 ;; \
	    esac; \
	wget "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz"; \
	if [ ! -d "/opt/" ]; then mkdir -p "/opt/"; fi; \ 
	tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C "/opt/" --no-same-owner; \ 
	rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz"; \
	ln -s "/opt/node-v$NODE_VERSION-linux-$ARCH" "/opt/node"; \
#
# Install frontail
#
	/opt/node/bin/npm i frontail -g; \
#
# Set permisions for application and nodejs directory
#
	chown -R "$SERVICE_USER":"$SERVICE_GROUP" "/opt/openhab/"; \
	chown -R "$SERVICE_USER":"$SERVICE_GROUP" "/opt/node-v$NODE_VERSION-linux-$ARCH"; \
#
# Clean the apt cache and remove packages needed only for the installation
#
	apt-get -y --purge remove ca-certificates wget unzip xz-utils apt-utils; \
	apt -y autoremove; \
	apt-get clean -y; \
	rm -rf /var/lib/apt/lists/*; 

#
# Create the Configuration directory
#
# VOLUME	/opt/openhab/conf /opt/openhab/userdata /opt/openhab/addons
#
VOLUME	/home/${OPENHAB_SVC_NAME}/.openhab/

#
# Publish the web app ports
#
# EXPOSE	8080 8443 9001 5007
#
EXPOSE "${OPENHAB_HTTP_PORT}" "${OPENHAB_HTTPS_PORT}"  "${OPENHAB_FRONTTAIL_PORT}" "${OPENHAB_LSP_PORT}"


#
# Copy the frontail openhab config files
#
COPY	frontail.dist/frontail-preset.json /opt/node/lib/node_modules/frontail/preset/openhab.json
COPY	frontail.dist/frontail-theme.css /opt/node/lib/node_modules/frontail/web/assets/styles/openhab.css
RUN		chown -R "${OPENHAB_SVC_NAME}":"${OPENHAB_SVC_NAME}" /opt/node/lib/node_modules/frontail/
#
# Copy the start command
#
COPY	openhab-run.sh "/opt/openhab/openhab-run.sh"
RUN		chown "${OPENHAB_SVC_NAME}":"${OPENHAB_SVC_NAME}" "/opt/openhab/openhab-run.sh" && chmod +x "/opt/openhab/openhab-run.sh"

USER		${OPENHAB_SVC_UID}
WORKDIR 	"/opt/openhab/"
ENTRYPOINT	[ "/opt/openhab/openhab-run.sh" ]
CMD			["./start.sh"]
#
#
# For testing and debugging comment out the above ENTRYPOINT, CMD and uncomment the following
#
#WORKDIR "/home/${OPENHAB_SVC_NAME}/"
#ENTRYPOINT [ "/bin/bash" ]