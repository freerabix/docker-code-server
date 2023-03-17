#!/bin/bash
set -e

#echo "$@"
#export

if [ "$ENV_VS_EXTENSIONS_GALLERY" = true ]; then
    export EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"}'
fi

#if [ "$PASSWORD" = false ]; then
#    AUTH=none
#else
#    AUTH=password
#fi

##todo: exist .gitconfig file?
if [ "$ENV_GIT_NAME" != "" ] || [ "$ENV_GIT_EMAIL" != "" ]; then
    git config --global user.name $ENV_GIT_NAME
    git config --global user.email $ENV_GIT_EMAIL
else
    echo "set ENV_GIT_NAME and ENV_GIT_EMAIL"
    exit
fi

exec "$@"
#/usr/bin/code-server "$@"
#/usr/bin/code-server --bind-addr $IFBIND --auth password --disable-telemetry --disable-update-check $WORKSPACE
