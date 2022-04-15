FROM ich777/novnc-baseimage

LABEL maintainer="docker@h-filip.de"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends cifs-utils sudo curl curlftpfs davfs2 cryfs fonts-takao libgtk2.0 midori xdg-utils && \
	echo "ko_KR.UTF-8 UTF-8" >> /etc/locale.gen && \ 
	echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "FreeFileSync - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

ENV DATA_DIR=/freefilesync
ENV REMOTE_DIR="192.168.1.1"
ENV REMOTE_TYPE="local"
ENV REMOTE_USER=""
ENV REMOTE_PWD=""
ENV CRYFS=""
ENV CRYFS_PWD=""
ENV CRYFS_BLOCKSIZE=262144
ENV CRYFS_EXTRA_PARAMETERS=""
ENV DL_URL="https://freefilesync.org/download/FreeFileSync_11.18_Linux.tar.gz"
ENV CUSTOM_RES_W=1280
ENV CUSTOM_RES_H=800
ENV CUSTOM_DEPTH=16
ENV TURBOVNC_PARAMS="-securitytypes none"
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
ENV START_PARAMS=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="freefilesync"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048 && \
	echo "$USER ALL=(root) NOPASSWD:/bin/mount" >> /etc/sudoers && \
    echo "$USER ALL=($USER) NOPASSWD:ALL" >> /etc/sudoers

ADD /scripts/ /opt/scripts/
COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /conf/ /etc/.fluxbox/
RUN chmod -R 770 /opt/scripts/ && \
	chown -R ${UID}:${GID} /mnt && \
	chmod -R 770 /mnt

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]