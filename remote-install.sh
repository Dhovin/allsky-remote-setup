#!/bin/bash
REMOTE_USER=
REMOTE_SYSTEM=

#if [$REMOTE_USER -eq "root"]; then

ssh-keygen -t rsa
ssh-copy-id ${remoteuser}@${remotesystem}

ssh ${remoteuser}@${remotesystem} "wget && sudo chmod +x remote-setup.sh && ./remotesetup.sh"

#add group write permissions
ns
chmod g+w allsky/ -R