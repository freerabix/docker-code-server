#!/bin/bash
set -e

if [ "$ENV_VS_EXTENSIONS_GALLERY" = true ]; then
    export EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"}'
fi

if [ ! -f "/app/config/.gitconfig" ]; then
    if [ "$ENV_GIT_NAME" != "" ] || [ "$ENV_GIT_EMAIL" != "" ]; then
        git config --global user.name $ENV_GIT_NAME
        git config --global user.email $ENV_GIT_EMAIL
    else
        echo "set ENV_GIT_NAME and ENV_GIT_EMAIL"
        exit
    fi
fi

exec "$@"
#/usr/bin/code-server "$@"
#/usr/bin/code-server --bind-addr $IFBIND --auth password --disable-telemetry --disable-update-check $WORKSPACE
