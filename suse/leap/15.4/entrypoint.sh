#!/bin/bash
set -e

if [ "$ENV_VS_EXTENSIONS_GALLERY" = true ]; then
    export EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"}'
fi

if [ "$ENV_WEB_PASSWORD" != "" ]; then
    SALT=`cat /dev/urandom | head -c 10 | base64`
    export HASHED_PASSWORD=`echo -n "$ENV_WEB_PASSWORD" | argon2 $SALT -e`
    unset ENV_WEB_PASSWORD
    unset PASSWORD
    unset SALT
fi

if [ "$ENV_USER_PASSWORD" != "" ]; then
    echo -e "${ENV_USER_PASSWORD}\n${ENV_USER_PASSWORD}" | passwd $ENV_USER_NAME 2> /dev/null
    unset ENV_USER_PASSWORD

    echo "$ENV_USER_NAME ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers.d/nopasswd > /dev/null
    ##suse: lines must be removed
    sed -i 's/^Defaults targetpw/#Defaults targetp/' /etc/sudoers
    sed -i 's/^ALL   ALL=(ALL) ALL/#ALL   ALL=(ALL) ALL/' /etc/sudoers
    #echo "code ALL=(ALL:ALL) ALL" >> /etc/sudoers
    #set linux user password
    #echo -e "${SUDO_PASSWORD}\n${SUDO_PASSWORD}" | passwd abc
fi

if [ "$ENV_GIT_NAME" != "" ] && [ "$ENV_GIT_EMAIL" != "" ]; then
    /usr/local/sbin/gosu $ENV_USER_NAME git config --global user.name $ENV_GIT_NAME
    /usr/local/sbin/gosu $ENV_USER_NAME git config --global user.email $ENV_GIT_EMAIL
    unset ENV_GIT_NAME
    unset ENV_GIT_EMAIL
fi

#mydomain.com
#reverse_proxy 0.0.0.0:8443

unset ENV_UID
unset ENV_VS_EXTENSIONS_GALLERY

###service
exec /usr/local/sbin/gosu $ENV_USER_NAME "$@"




#exec "$@"
#/usr/bin/code-server "$@"
#exec /usr/local/bin/gosu code /usr/bin/code-server --bind-addr $ENV_IFBIND:8443 --auth password --disable-telemetry --disable-update-check $ENV_WORKSPACE
