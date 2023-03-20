#!/bin/bash
set -e

if [ "$ENV_VS_EXTENSIONS_GALLERY" = true ]; then
    export EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"}'
    unset ENV_VS_EXTENSIONS_GALLERY
fi

if [ "$ENV_USER_PASSWORD" != "" ]; then
    #echo set password
    echo -e "${ENV_USER_PASSWORD}\n${ENV_USER_PASSWORD}" | passwd $ENV_USER_NAME
    unset ENV_USER_PASSWORD

    ##todo: sudo nopasswd creation
    echo "$ENV_USER_NAME ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers.d/nopasswd > /dev/null
    ##suse: lines must be removed
    sed -i 's/^Defaults targetpw/#Defaults targetp/' /etc/sudoers
    sed -i 's/^ALL   ALL=(ALL) ALL/#ALL   ALL=(ALL) ALL/' /etc/sudoers
    #echo "code ALL=(ALL:ALL) ALL" >> /etc/sudoers
    #set linux user password
    #echo -e "${SUDO_PASSWORD}\n${SUDO_PASSWORD}" | passwd abc
fi

#if [ ! -f "/app/config/.gitconfig" ]; then
if [ "$ENV_GIT_NAME" != "" ] && [ "$ENV_GIT_EMAIL" != "" ]; then
    gosu $ENV_USER_NAME git config --global user.name $ENV_GIT_NAME
    gosu $ENV_USER_NAME git config --global user.email $ENV_GIT_EMAIL
    unset ENV_GIT_NAME
    unset ENV_GIT_EMAIL
#else
    #todo: if [ ! -f "/app/config/.gitconfig" ]; then
#    echo "set ENV_GIT_NAME and ENV_GIT_EMAIL"
#    exit
fi
#fi
if [ "$@" = "" ]; then
#sbin?
#exec /usr/local/bin/gosu $ENV_USER_NAME "$@"
#exec "$@"
#/usr/bin/code-server "$@"
exec /usr/local/bin/gosu code /usr/bin/code-server --bind-addr $ENV_IFBIND:8443 --auth password --disable-telemetry --disable-update-check $ENV_WORKSPACE

else 
exec /usr/local/bin/gosu code "$@"
fi