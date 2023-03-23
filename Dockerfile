###template: https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile

ARG ARG_
ARG ARG_OS_URL="alpine"
ARG ARG_OS_VERSION="3.15"
FROM --platform=amd64 ${ARG_OS_URL}:${ARG_OS_VERSION} as packages

ARG ARG_CODE_SERVER_VERSION="4.11.0"
#ARG ARG_GOSU_VERSION="1.16"
#ARG ARG_TINI_VERSION="v0.19.0"

RUN apk update && \
apk add tar gzip xz wget
#zypper -n clean && rm -r /var/log/*

###set permission: cleaning
#RUN setfacl -R -b  /tmp/rootfs
RUN mkdir -p /rootfs/opt/npm && \
mkdir -p /rootfs/app/workspace && \
mkdir -p /rootfs/app/config

COPY --chown=root:root entrypoint.sh /rootfs

RUN apk update && \
apk add tzdata bash npm nodejs yarn python3 curl build-base libstdc++ libc6-compat alpine-sdk && \
npm config set prefix /rootfs/opt/npm && \
npm install -g code-server@^${ARG_CODE_SERVER_VERSION} --unsafe-perm && \
cd /rootfs/opt/npm/lib/node_modules/code-server/lib/vscode && yarn
#npm config set python python3




######MAIN######
FROM --platform=amd64 ${ARG_OS_URL}:${ARG_OS_VERSION}


#ARG ARG_WORKSPACE="/app/workspace"
#ARG ARG_PORT=8443
#ARG ARG_IFBIND="0.0.0.0"
#ARG ARG_VS_EXTENSIONS_GALLERY=false
#ARG ARG_WEB_PASSWORD=hallo
#ARG ARG_USER_PASSWORD=hallo
#ARG ARG_GIT_NAME
#ARG ARG_GIT_EMAIL
#ARG ARG_USER_NAME=code
#ARG ARG_UID=10001
#ARG ARG_GID=10001
#todo add uid

ENV TZ="Europe/Berlin"
ENV ENV_WEB_PASSWORD="hallo"
ENV ENV_USER_PASSWORD="hallo"
ENV ENV_USER_NAME=code
ENV ENV_UID=10001
ENV ENV_VS_EXTENSIONS_GALLERY=false
ENV ENV_PORT=8443
ENV ENV_IFBIND="0.0.0.0"
ENV ENV_WORKSPACE="/app/workspace"
ENV ENV_GIT_NAME=""
ENV ENV_GIT_EMAIL=""

#openssh git-lfs nano man zsh curl locales
#git lfs install
COPY --from=packages /rootfs /

RUN apk update && \
#caddy
apk add tini su-exec git sudo argon2 bash nodejs libstdc++ libc6-compat

RUN adduser -u $ENV_UID -H -D -h /app/config $ENV_USER_NAME && \
chown -R ${ENV_USER_NAME}:users /app && \
chmod +x /entrypoint.sh

EXPOSE $ENV_PORT
WORKDIR $ENV_WORKSPACE
ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]
CMD /opt/npm/bin/code-server --bind-addr $ENV_IFBIND:$ENV_PORT --auth password --disable-telemetry --disable-update-check $ENV_WORKSPACE
