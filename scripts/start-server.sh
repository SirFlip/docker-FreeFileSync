#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority
DL_V=$(echo "${DL_URL}" | cut -d '_' -f 2)
CUR_V="$(find $DATA_DIR -name freefilesync-* | cut -d '-' -f 2)"

echo "---Checking for FreeFileSync---"
if [ "$DL_V" == "$CUR_V" ]; then
    echo "---FreeFileSync found---"
elif [ -z "$CUR_V" ]; then
    echo "---FreeFileSync not found, downloading...---"
    cd ${DATA_DIR}
    curl https://freefilesync.org/download.php > /dev/null
    if wget -q -nc --show-progress --progress=bar:force:noscroll "${DL_URL}" ; then
        echo "---Successfully downloaded FreeFileSync---"
    else
        echo "-------------------------------------------------------"
        echo "--Something went wrong couldn't download FreeFileSync--"
        echo "------Please make sure to put in the Linux version-----"
        echo "---------------in the DL_URL variable------------------"
        echo "--------Example: FreeFileSync_1.53_Linux.tar.gz--------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
    tar -xzf FreeFileSync_${DL_V}_Linux.tar.gz
    ./FreeFileSync_${DL_V}_Install.run --accept-license --directory ${DATA_DIR}/FreeFileSync-Linux --for-all-users false --create-shortcuts false --skip-overview
    if [ ! -d ${DATA_DIR}/FreeFileSync-Linux ]; then
        echo "-------------------------------------------------------"
        echo "--Something went wrong couldn't extract FreeFileSync---"
        echo "-----------Putting server into sleep mode--------------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
    touch freefilesync-$DL_V
    rm -R FreeFileSync_${DL_V}_Linux.tar.gz FreeFileSync_${DL_V}_Install.run 2>/dev/null
    CUR_V="$(find $DATA_DIR -name freefilesync-* | cut -d '-' -f 2)"
elif [ "$DL_V" != "$CUR_V" ]; then
    echo "-------------------------------------------"
    echo "---Version missmatch installed version: $CUR_V---"
    echo "------------Preferred versifon: $DL_V-----------"
    echo "----------Installing version: $DL_V-----------"
    echo "-------------------------------------------"
    cd ${DATA_DIR}
    rm -R freefilesync-$CUR_V 2>/dev/null
    curl https://freefilesync.org/download.php > /dev/null
    if wget -q -nc --show-progress --progress=bar:force:noscroll "${DL_URL}" ; then
        echo "---Successfully downloaded FreeFileSync---"
    else
        echo "-------------------------------------------------------"
        echo "--Something went wrong couldn't download FreeFileSync--"
        echo "------Please make sure to put in the Linux version-----"
        echo "---------------in the DL_URL variable------------------"
        echo "--------Example: FreeFileSync_1.53_Linux.tar.gz--------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
    tar -xzf FreeFileSync_${DL_V}_Linux.tar.gz
    ./FreeFileSync_${DL_V}_Install.run --accept-license --directory ${DATA_DIR}/FreeFileSync-Linux --for-all-users false --create-shortcuts false --skip-overview
    if [ ! -d ${DATA_DIR}/FreeFileSync-Linux ]; then
        echo "-------------------------------------------------------"
        echo "--Something went wrong couldn't extract FreeFileSync---"
        echo "-----------Putting server into sleep mode--------------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
    touch freefilesync-$DL_V
    rm -R FreeFileSync_${DL_V}_Linux.tar.gz FreeFileSync_${DL_V}_Install.run 2>/dev/null
    CUR_V="$(find $DATA_DIR -name freefilesync-* | cut -d '-' -f 2)"
fi

if [ "${CRYFS}" == "true" ]; then
    export CRYFS_FRONTEND=noninteractive
    if [ ! -d ${DATA_DIR}/cryfs ]; then
        mkdir ${DATA_DIR}/cryfs
    fi
    if [ ! -d /tmp/cryfs ]; then
        mkdir /tmp/cryfs
    fi
    if [ -z "$CRYFS_PWD" ]; then
        echo "----------------------------------------------"
        echo "--------No CryFS password set, please---------"
        echo "---set a password and restart the container---"
        echo "----------------------------------------------"
        sleep infinity
    fi
    if [ "${REMOTE_TYPE}" == "smb" ]; then
        echo "----------------------------------------------------"
        echo "---SMB mounting inside the container is removed!----"
        echo "---Please mount your share through the Unassigned---"
        echo "---Devices Plugin and select the mode 'local' in----"
        echo "----the template and mount the share inside the ----"
        echo "---------------------container!---------------------"
        echo "----------------------------------------------------"
        sleep infinity
    fi
    
    if [ "${REMOTE_TYPE}" == "ftp" ]; then
        if [ ! -d /mnt/ftp ]; then
            mkdir /mnt/ftp
        fi
        if curlftpfs ${REMOTE_USER}:${REMOTE_PWD}@${REMOTE_DIR} /tmp/cryfs ; then
            echo "---Mounted ${REMOTE_DIR} to /mnt/ftp---"
        else
            echo "---Couldn't mount ${REMOTE_DIR}---"
            sleep infinity
        fi
        if echo "${CRYFS_PWD}" | cryfs -c ${DATA_DIR}/cryfs/cryfs.cfg --logfile ${DATA_DIR}/cryfs/cryfs.log --blocksize ${CRYFS_BLOCKSIZE} ${CRYFS_EXTRA_PARAMETERS} /tmp/cryfs/ /mnt/ftp/; then
            echo "---Starting CryFS encryption---"
        else
            echo "---Couldn't start CryFS encryption of ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi

    if [ "${REMOTE_TYPE}" == "webdav" ]; then
        if [ ! -d /mnt/webdav ]; then
            mkdir /mnt/webdav
        fi
        if echo "${REMOTE_PWD}" | sudo mount -t davfs -o noexec,username=${REMOTE_USER},rw,uid=${UID},gid=${GID} ${REMOTE_DIR} /tmp/webdav/ ; then
            echo "---Mounted ${REMOTE_DIR} to /mnt/webdav---"
        else
            echo "---Couldn't mount ${REMOTE_DIR}---"
            sleep infinity
        fi
        if echo "${CRYFS_PWD}" | cryfs -c ${DATA_DIR}/cryfs/cryfs.cfg --logfile ${DATA_DIR}/cryfs/cryfs.log --blocksize ${CRYFS_BLOCKSIZE} ${CRYFS_EXTRA_PARAMETERS} /tmp/cryfs/ /mnt/webdav/ ; then
            echo "---Starting CryFS encryption---"
        else
            echo "---Couldn't start CryFS encryption of ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi

    if [ "${REMOTE_TYPE}" == "local" ]; then
      if [ ! -d /mnt/local ]; then
          echo "------------------------------------------------------------------------"
          echo "--------Encryption enabled! Path '/mnt/local' not found, please---------"
          echo "---be sure to mount a volume to this path while encryption is enabled---"
          echo "------------------------------------------------------------------------"
          sleep infinity
      fi
        if echo "${CRYFS_PWD}" | cryfs -c ${DATA_DIR}/cryfs/cryfs.cfg --logfile ${DATA_DIR}/cryfs/cryfs.log --blocksize ${CRYFS_BLOCKSIZE} ${CRYFS_EXTRA_PARAMETERS} /tmp/cryfs/ /mnt/local/ ; then
            echo "---Starting CryFS encryption---"
        else
            echo "---Couldn't start CryFS encryption of ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi
else
    if [ "${REMOTE_TYPE}" == "smb" ]; then
        echo "----------------------------------------------------"
        echo "---SMB mounting inside the container is removed!----"
        echo "---Please mount your share through the Unassigned---"
        echo "---Devices Plugin and select the mode 'local' in----"
        echo "----the template and mount the share inside the ----"
        echo "---------------------container!---------------------"
        echo "----------------------------------------------------"
        sleep infinity
    fi

    if [ "${REMOTE_TYPE}" == "ftp" ]; then
        if [ ! -d /mnt/ftp ]; then
            mkdir /mnt/ftp
        fi
        if curlftpfs ${REMOTE_USER}:${REMOTE_PWD}@${REMOTE_DIR} /mnt/ftp ; then
            echo "---Mounted ${REMOTE_DIR} to /mnt/ftp---"
        else
            echo "---Couldn't mount ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi

    if [ "${REMOTE_TYPE}" == "webdav" ]; then
        if [ ! -d /mnt/webdav ]; then
            mkdir /mnt/webdav
        fi
        if echo "${REMOTE_PWD}" | sudo mount -t davfs -o noexec,username=${REMOTE_USER},rw,uid=${UID},gid=${GID} ${REMOTE_DIR} /mnt/webdav/ ; then
            echo "---Mounted ${REMOTE_DIR} to /mnt/webdav---"
        else
            echo "---Couldn't mount ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi

    if [ "${REMOTE_TYPE}" == "local" ]; then
        echo "---Local mounting is selected, please mount your local path to the container---"
    fi
fi

echo "---Preparing Server---"
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
chmod -R ${DATA_PERM} ${DATA_DIR}
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
    chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null


echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}

echo "---Starting FreeFileSync---"
echo $HOME
echo ~
${DATA_DIR}/FreeFileSync-Linux/FreeFileSync ${START_PARAMS}
