
#!/bin/bash
set -eu

if [ "$VS_EXTENSIONS_GALLERY" = true ]; then
    export EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"}'
fi

#if [ "$PASSWORD" = false ]; then
#    AUTH=none
#else
#    AUTH=password
#fi

if [ "$GIT_NAME" != "" ] || [ "$GIT_NAME" != "" ]; then
    git config --global user.name $GIT_NAME
    git config --global user.email $GIT_EMAIL
else
    echo "NO GIT_NAME or GIT_EMAIL IS SET!"
    exit
fi


#/usr/bin/code-server "$@"
#/usr/bin/code-server --bind-addr $IFBIND --auth password --disable-telemetry --disable-update-check $WORKSPACE
