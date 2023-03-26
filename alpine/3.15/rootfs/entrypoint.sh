#!/bin/bash
set -e

##time
if [ ! -f "/etc/timezone" ]; then
    echo "$TZ" > /etc/timezone && \
    cp /usr/share/zoneinfo/"$TZ" /etc/localtime
fi


if [ "$ENV_WEB_PASSWORD" != "" ]; then
    SALT=`cat /dev/urandom | head -c 10 | base64`
    export HASHED_PASSWORD=`echo -n "$ENV_WEB_PASSWORD" | argon2 $SALT -e`
    unset ENV_WEB_PASSWORD
    unset PASSWORD
    unset SALT
fi

##set run user password
if  [ "$ENV_USER_PASSWORD" != "" ]; then
    echo -e "${ENV_USER_PASSWORD}\n${ENV_USER_PASSWORD}" | passwd $ENV_RUN_USER  > /dev/null 2> /dev/null
fi

##set run user sudo
if [ "$ENV_USER_PASSWORD" != "" ] && [ "$ENV_RUN_USER" != "root" ]; then
    echo "$ENV_RUN_USER ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers.d/nopasswd > /dev/null
    unset ENV_USER_PASSWORD
fi

if [ "$ENV_GIT_NAME" != "" ] && [ "$ENV_GIT_EMAIL" != "" ]; then
    /sbin/su-exec $ENV_RUN_USER git config --global user.name $ENV_GIT_NAME
    /sbin/su-exec $ENV_RUN_USER git config --global user.email $ENV_GIT_EMAIL
    unset ENV_GIT_NAME
    unset ENV_GIT_EMAIL
fi

if [ "$ENV_VS_EXTENSIONS_GALLERY" = true ]; then
    export EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"}'
fi



#TODO: caddy ssl proxy
#mydomain.com
#reverse_proxy 0.0.0.0:8443

unset ENV_UID
unset ENV_GID
unset ENV_VS_EXTENSIONS_GALLERY


exec /sbin/su-exec $ENV_RUN_USER "$@"



#if [ ! -f "$/app/config/certs" ]; then
    #cd /app/config/certs
    #openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365
#fi

#if [ "$ENV_OH_MY_ZSH" = true ]; then
#    if [ ! -d /app/config/.oh-my-zsh ]; then
#        /sbin/su-exec $ENV_USER_NAME /bin/bash -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" &
#        sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd
#    fi
#else
#    rm -r /app/config/.oh-my-zsh
#    sed -i -e "s/bin\/zsh/bin\/ash/" /etc/passwd
#fi