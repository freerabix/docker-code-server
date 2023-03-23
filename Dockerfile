###template: https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile

#ARG ARG_CPU_ARCH="amd64"
ARG ARG_OS_URL="alpine"
ARG ARG_OS_VERSION="3.15"
FROM --platform=amd64 ${ARG_OS_URL}:${ARG_OS_VERSION} as packages

ARG ARG_CODE_SERVER_VERSION="4.11.0"
#ARG ARG_GOSU_VERSION="1.16"
#ARG ARG_TINI_VERSION="v0.19.0"

RUN apk update && \
apk add tar gzip xz wget
#zypper -n clean && rm -r /var/log/*

RUN mkdir -p /rootfs
###set permission: cleaning
#RUN setfacl -R -b  /tmp/rootfs
#RUN mkdir -p /rootfs/opt/npm && \
#mkdir -p /rootfs/app/workspace && \
#mkdir -p /rootfs/app/config && \
#mkdir -p /rootfs/root
COPY --chown=root:root rootfs /rootfs
#COPY --chown=root:root entrypoint.sh /rootfs
#COPY --chown=root:root .bashrc /rootfs/root
#COPY --chown=root:root .bashrc /rootfs/app/config

RUN apk update && \
apk add tzdata bash npm nodejs yarn python3 curl libstdc++ libc6-compat alpine-sdk && \
npm config set prefix /rootfs/opt/npm && \
npm install -g code-server@^${ARG_CODE_SERVER_VERSION} --unsafe-perm && \
cd /rootfs/opt/npm/lib/node_modules/code-server/lib/vscode && yarn
#npm config set python python3




######MAIN######
FROM --platform=amd64 ${ARG_OS_URL}:${ARG_OS_VERSION}

ENV TZ="Europe/Berlin"
ENV ENV_WEB_PASSWORD=""
ENV ENV_USER_PASSWORD=""
ENV ENV_USER_NAME=code
ENV ENV_UID=10001
ENV ENV_VS_EXTENSIONS_GALLERY=false
ENV ENV_PORT=8443
ENV ENV_IFBIND="0.0.0.0"
ENV ENV_WORKSPACE="/app/workspace"
ENV ENV_GIT_NAME=""
ENV ENV_GIT_EMAIL=""
#ENV PS1='\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ '
#ENV ENV_OH_MY_ZSH=true

#openssh git-lfs nano man zsh curl locales
#git lfs install
COPY --from=packages /rootfs /

#todo: caddy
RUN apk update && \
#    apk add zsh git vim zsh-autosuggestions zsh-syntax-highlighting bind-tools curl && \
apk add tzdata nano wget curl tini su-exec git git-lfs sudo argon2 bash figlet zsh zsh-autosuggestions zsh-syntax-highlighting nodejs libstdc++ libc6-compat && \
echo "$TZ" > /etc/timezone && \
cp /usr/share/zoneinfo/"$TZ" /etc/localtime && \
apk del tzdata && \
rm -rf /var/cache/apk/*

RUN adduser -u $ENV_UID -H -D -h /app/config $ENV_USER_NAME && \
chown -R ${ENV_USER_NAME}:users /app && \
chmod +x /entrypoint.sh

##oh my zsh
RUN /sbin/su-exec $ENV_USER_NAME /bin/bash -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" && \
sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd 


EXPOSE $ENV_PORT
WORKDIR $ENV_WORKSPACE
VOLUME ["/app","/tmp","/var/log"]
ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]
CMD /opt/npm/bin/code-server --bind-addr $ENV_IFBIND:$ENV_PORT --auth password --disable-telemetry --disable-update-check $ENV_WORKSPACE
