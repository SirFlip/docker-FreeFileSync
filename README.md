# FreeFileSync in Docker optimized for Unraid
This Docker will download and install FreeFileSync. You can sync your files to another offsite SMB, FTP and WebDAV share with encryption by CryFS.
You can also use this tool to duplicate your files on the server to another directory.

Encryption by CryFS is also supported if you want to sync your files to an external server and have extra security (see the Run example with encryption by CryFS). CryFS splits (according to the set blocksize) and encrypts your files with aes-256-gcm and your choosen password.

Please also check out the Developers website of FreeFileSync: https://freefilesync.org/ and from CryFS: https://www.cryfs.org/

Based on [DirSyncPro-Docker](https://github.com/ich777/docker-dirsyncpro) from [ich777](https://github.com/ich777)

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for FreeFileSync | /freefilesync |
| REMOTE_DIR| Depending on the Remote Type fill in your connection informations for local: 'leave empty' - smb: '192.168.1.1/backup' - ftp: '192.168.1.1' - webdav: 'https://nextcloud.host.com/remote.php/webdav' | 192.168.1.1 |
| REMOTE_TYPE | Currently 'local', 'smb', 'ftp' and 'webdav' are available | local |
| REMOTE_USER | Remote username (must be provided - not for 'local') | username |
| REMOTE_PWD | Remote password (must be provided - not for 'local') | password |
| CRYFS | Set to 'true' if you want encryption with CryFS | true |
| CRYFS_PWD | Set the encryption password for CryFS | password |
| CRYFS_BLOCKSIZE| Set the blocksize for your files in bytes (262144 Byte = 256 KiB) | 262144 |
| CRYFS_EXTRA_PARAMETERS | Extra parameters for CryFS if needed, otherwise leave blank | --unmount-idle 30 |
| START_PARAMS | Here you can set extra FreeFileSync start parameters | |
| DL_URL | Download URL for FreeFileSync | https://freefilesync.org/download/FreeFileSync_11.18_Linux.tar.gz ... |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |


>**NOTE** This Docker must be started with the follwoing parameters '--cap-add SYS_ADMIN', '--cap-add DAC_READ_SEARCH', and '--privileged=true'

## Run example
```
docker run --name FreeFileSync -d \
    -p 8080:8080 \
    --env 'REMOTE_TYPE=smb' \
    --env 'REMOTE_DIR=192.168.1.1' \
    --env 'REMOTE_USER=username' \
    --env 'REMOTE_PWD=password' \
    --env 'RUNTIME_NAME=jre1.8.0_211 \
    --env 'DL_URL=https://freefilesync.org/download/FreeFileSync_11.18_Linux.tar.gz' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/freefilesync:/freefilesync \
    --privileged=true \
    --cap-add SYS_ADMIN \
    --cap-add DAC_READ_SEARCH \
    --restart=unless-stopped \
    sirflip/freefilesync
```

## Run example with encryption by CryFS
```
docker run --name FreeFileSync -d \
    -p 8080:8080 \
    --env 'REMOTE_TYPE=smb' \
    --env 'REMOTE_DIR=192.168.1.1' \
    --env 'REMOTE_USER=username' \
    --env 'REMOTE_PWD=password' \
    --env 'CRYFS=true' \
    --env 'CRYFS_PWD=password' \
    --env 'CRYFS_BLOCKSIZE=262144' \
    --env 'RUNTIME_NAME=jre1.8.0_211 \
    --env 'DL_URL=https://freefilesync.org/download/FreeFileSync_11.18_Linux.tar.gz' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/freefilesync:/freefilesync \
    --privileged=true \
    --cap-add SYS_ADMIN \
    --cap-add DAC_READ_SEARCH \
    --restart=unless-stopped \
    sirflip/freefilesync
```

>**ENCRYPTION NOTE:** The mounted folder will be automaticaly encrypted (smb: '/mnt/smb' - ftp: '/mnt/ftp' - webdav: '/mnt/webdav' - local: if you set the type to 'local' you must set the container mountpoint to: '/mnt/local'). Please also note if you set up a encrypted share for the first time the destination folder should be empty since CryFS will create a folder with the basic information for the encryption and all the split files (don't delete any folder since it can corrupt files).
The docker will automaticaly create a directory named 'cryfs' in the main directory of FreeFileSync, please copy the 'cryfs.cfg' to a save place since you will need this file and your selected password for CryFS to decrypt the files.
Restoring of encrypted files on another computer/server with this Docker: start the container once with CryFS enabled but set no password, the container will start and create the 'cryfs' directory, stop the container copy your cryfs.cfg in the 'cryfs' folder edit the Docker and set the apropriate password and blocksize for the cryfs.cfg and restart the Docker. Now you can sync from/or to your encrypted share again.

### Webgui address: http://[SERVERIP]:[PORT]/vnc_auto.html

## Set VNC Password:
 Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or simply leave it empty:
```
    --env 'TURBOVNC_PARAMS='
```

Please check also the FreeFileSync Developers (Zenju) website out: https://freefilesync.org/ and the website from CryFS: https://www.cryfs.org/
