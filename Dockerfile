###template: https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile

ARG ARG_OS_VERSION="15.4"
ARG ARG_OS_URL="registry.opensuse.org/opensuse/leap"
FROM ${ARG_OS_URL}:${ARG_OS_VERSION} as packages

ARG ARG_CODE_SERVER_VERSION="4.10.1"
ARG ARG_GOSU_VERSION="1.16"
#ARG ARG_TINI_VERSION="v0.19.0"

#zypper --non-interactive install -t pattern devel_basis && \
RUN zypper --non-interactive update && \
zypper --non-interactive install tar gzip xz wget && \
zypper -n clean && rm -r /var/log/*


#create rootfs
#RUN mkdir -p /rootfs/app/{workspace,config} && mkdir -p /rootfs/usr/local/bin
#COPY entrypoint.sh /rootfs/usr/local/bin
#RUN chmod +x /rootfs/usr/local/bin/entrypoint.sh
#COPY code-server*.rpm /tmp
#ADD code-server-4.10.1-linux-amd64.tar.gz /tmp
#RUN wget https://github.com/coder/code-server/releases/download/v4.10.1/code-server-4.10.1-linux-amd64.tar.gz -O /tmp/code-server.tar.gz && mkdir /tmp/code-server &&  tar xf /tmp/code-server.tar.gz -C /tmp/code-server --strip-components=1
#ADD code-server-4.10.1-linux-amd64.tar.gz /tmp
#RUN zypper --non-interactive update && zypper --non-interactive install --allow-unsigned-rpm /tmp/code-server-4.10.1-amd64.rpm && zypper -n clean && rm -r /var/log/*

###set permission: cleaning
#COPY rootfs /tmp/rootfs
#RUN setfacl -R -b  /tmp/rootfs
RUN mkdir -p /rootfs/sbin
COPY --chown=root:root entrypoint.sh /rootfs/sbin
RUN wget https://github.com/tianon/gosu/releases/download/${ARG_GOSU_VERSION}/gosu-amd64 -O /rootfs/sbin/gosu
#RUN wget https://github.com/krallin/tini/releases/download/${ARG_TINI_VERSION}/tini -O /rootfs/sbin/tini
RUN wget https://github.com/coder/code-server/releases/download/v${ARG_CODE_SERVER_VERSION}/code-server-${ARG_CODE_SERVER_VERSION}-amd64.rpm -P /tmp



######MAIN######
#FROM registry.opensuse.org/opensuse/leap:15.4
FROM ${ARG_OS_URL}:${ARG_OS_VERSION}

ARG ARG_WORKSPACE="/app/workspace"
ARG ARG_PORT=8443
ARG ARG_IFBIND="0.0.0.0"
ARG ARG_VS_EXTENSIONS_GALLERY=false
ARG ARG_WEB_PASSWORD=hallo
ARG ARG_USER_PASSWORD=hallo
ARG ARG_GIT_NAME
ARG ARG_GIT_EMAIL
ARG ARG_USER_NAME=code
ARG ARG_UID=10001
#ARG ARG_GID=10001
#todo add uid

ENV ENV_WEB_PASSWORD=$ARG_WEB_PASSWORD
ENV ENV_USER_PASSWORD=$ARG_USER_PASSWORD
ENV ENV_USER_NAME=$ARG_USER_NAME
ENV ENV_UID=$ARG_UID
ENV ENV_VS_EXTENSIONS_GALLERY=$ARG_VS_EXTENSIONS_GALLERY
ENV ENV_PORT=$ARG_PORT
ENV ENV_IFBIND=$ARG_IFBIND
ENV ENV_WORKSPACE=$ARG_WORKSPACE
ENV ENV_GIT_NAME=$ARG_GIT_NAME
ENV ENV_GIT_EMAIL=$ARG_GIT_EMAIL

#openssh git-lfs nano man zsh curl locales
#git lfs install
RUN zypper --non-interactive update && zypper --non-interactive install tini git sudo argon2 code-server && zypper -n clean && rm -r /var/log/*
RUN --mount=from=packages,src=/tmp,dst=/tmp zypper --non-interactive install --allow-unsigned-rpm /tmp/code-server*.rpm && zypper -n clean && rm -r /var/log/*

COPY --from=packages /rootfs/sbin /usr/local/sbin
RUN mkdir -p /app/{workspace,config} && useradd -u $ENV_UID -d /app/config $ENV_USER_NAME && chown -R ${ENV_USER_NAME}:users /app && chmod +x /usr/local/sbin/*


#todo: create rootfs
##todo: tinit
#USER code
#ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
ENTRYPOINT ["/tini","--","/usr/local/sbin/entrypoint.sh"]

EXPOSE $ENV_PORT
#VOLUME /app /var/log /tmp

##must be here and rest must follow!
#USER code
WORKDIR $ENV_WORKSPACE
#CMD ["/usr/bin/code-server","--bind-addr", "$ENV_IFBIND:9090"]
CMD /usr/bin/code-server --bind-addr $ENV_IFBIND:$ENV_PORT --auth password --disable-telemetry --disable-update-check $ENV_WORKSPACE
#CMD ["/usr/bin/code-server","--auth","password"]
#COPY --from=packages /tmp/code-server /usr/local
#ADD code-server-4.10.1-linux-amd64.tar.gz /usr/local

#RUN chmod +x /opt/entrypoint.sh
#RUN chown code /usr/local/bin/entrypoint.sh
#--bind-addr $IFBIND --disable-telemetry --disable-update-check $WORKSPACE

#config.yaml: password, bind-addr
#not needed: --bind-addr 0.0.0.0:8443 --auth password
#CMD code-server --disable-telemetry --disable-update-check /app/workspace
