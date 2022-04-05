#!/bin/bash
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
    echo "---Found optional script, executing---"
    chmod +x /opt/scripts/user.sh
    /opt/scripts/user.sh
else
    echo "---No optional script found, continuing---"
fi

echo "---Checking configuration for noVNC---"
novnccheck

echo "---Starting...---"
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
find /var/run/mount.davfs -name "*.pid" -exec rm -f {} \; 2> /dev/null
chown -R ${UID}:${GID} ${DATA_DIR}

# FreeFileSync to save config
ln -s ${DATA_DIR}/ /home/${USER}
chown -R ${UID}:${GID} /home/${USER}

term_handler() {
    kill -SIGINT "$(pidof FreeFileSync)"
    tail --pid="$(pidof FreeFileSync)" -f 2>/dev/null
    exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
    wait $killpid
    exit 0;
done
