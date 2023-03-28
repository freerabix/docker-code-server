###template: https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile

#ARG ARG_CPU_ARCH="amd64"
ARG ARG_REGISTRY
ARG ARG_BASE_IMAGE="alpine"
ARG ARG_BASE_TAG="3.15"
FROM --platform=amd64 ${ARG_REGISTRY}${ARG_BASE_IMAGE}:${ARG_BASE_TAG} as build

ARG ARG_CODE_SERVER_VERSION="4.11.0"
#ARG ARG_GOSU_VERSION="1.16"
#ARG ARG_TINI_VERSION="v0.19.0"

RUN apk update && \
apk add --no-cache tzdata bash npm nodejs yarn python3 curl libstdc++ libc6-compat alpine-sdk

RUN mkdir -p /rootfs
#--chown=root:root 
COPY rootfs /rootfs


RUN npm config set prefix /rootfs/opt/npm && \
npm install -g code-server@^${ARG_CODE_SERVER_VERSION} --unsafe-perm && \
cd /rootfs/opt/npm/lib/node_modules/code-server/lib/vscode && yarn


FROM --platform=amd64 ${ARG_REGISTRY}${ARG_BASE_IMAGE}:${ARG_BASE_TAG}

ENV TZ="Europe/Berlin"
ENV ENV_WEB_PASSWORD=""
ENV ENV_USER_PASSWORD=""
ENV ENV_USER_NAME=app
ENV ENV_RUN_USER=app
ENV ENV_UID=10001
ENV ENV_GID=10001
ENV ENV_VS_EXTENSIONS_GALLERY=false
ENV ENV_PORT=8443
ENV ENV_IFBIND="0.0.0.0"
ENV ENV_WORKSPACE="/app/workspace"
ENV ENV_GIT_NAME=""
ENV ENV_GIT_EMAIL=""

#todo: caddy
RUN apk update && \
apk add --no-cache tzdata nano wget curl tini su-exec git git-lfs libsecret sudo argon2 bash figlet zsh zsh-autosuggestions zsh-syntax-highlighting nodejs libstdc++ libc6-compat && \
rm -rf /var/cache/apk/*

#openssh git-lfs nano man zsh curl locales
COPY --from=build /rootfs /

#TODO: GID?
RUN adduser -u $ENV_UID -H -D -h /app/config -s /bin/zsh $ENV_USER_NAME && \
chown -R ${ENV_UID}:${ENV_GID} /app && \
chmod +x /entrypoint.sh && \
chmod 700 /entrypoint.sh

##oh my zsh for root and user
RUN /bin/bash -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" && \
/sbin/su-exec $ENV_USER_NAME /bin/bash -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" && \
sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd 


EXPOSE $ENV_PORT
#WORKDIR $ENV_WORKSPACE
VOLUME ["/app","/tmp","/var/log"]
ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]
CMD /opt/npm/bin/code-server --bind-addr $ENV_IFBIND:$ENV_PORT --auth password --disable-telemetry --disable-update-check $ENV_WORKSPACE


#LABEL org.label-schema.schema-version="1.0" \
#	org.label-schema.license="nothing" \
#	org.label-schema.name="secdocker-code-server" \
#	org.label-schema.description="A secure docker container for code server" \
#	org.label-schema.url="https://github.com/freerabix/docker-code-server" \
#	org.label-schema.vcs-url="https://github.com/freerabix/docker-code-server.git" \
#	org.label-schema.cmd="docker run --rm -ti freerabix/docker-code-server"





#FROM cs as cs.cpp
#RUN apk update && apk add --no-cache alpine-sdk clang make automake autoconf cmake pkgconf


#FROM --platform=amd64 code-server as coder-server-java
#RUN apk update && apk add --no-cache alpine-sdk

#FROM --platform=amd64 code-server as coder-server-sdk
#RUN apk update && apk add --no-cache alpine-sdk


#RUN apk update && \
#apk add --no-cache tar gzip xz wget
#zypper -n clean && rm -r /var/log/*

###set permission: cleaning
#RUN setfacl -R -b  /tmp/rootfs
#RUN mkdir -p /rootfs/opt/npm && \
#mkdir -p /rootfs/app/workspace && \
#mkdir -p /rootfs/app/config && \
#mkdir -p /rootfs/root
#COPY --chown=root:root entrypoint.sh /rootfs
#COPY --chown=root:root .bashrc /rootfs/root
#COPY --chown=root:root .bashrc /rootfs/app/config

#RUN apk update && \
#apk add --no-cache tzdata bash npm nodejs yarn python3 curl libstdc++ libc6-compat alpine-sdk && \
#npm config set prefix /rootfs/opt/npm && \
#npm install -g code-server@^${ARG_CODE_SERVER_VERSION} --unsafe-perm && \
#cd /rootfs/opt/npm/lib/node_modules/code-server/lib/vscode && yarn
#npm config set python python3

