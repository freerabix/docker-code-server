###template: https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile


ARG SUSE_BCI_BASE_VERSION="15.4"
FROM registry.suse.com/bci/bci-base:${SUSE_BCI_BASE_VERSION} as packages

ARG ARG_CODE_SERVER_VERSION="4.10.1"
#ENV ENV_CODE_SERVER_VERSION=$ARG_CODE_SERVER_VERSION

RUN zypper --non-interactive update && zypper --non-interactive install tar gzip xz wget acl && zypper -n clean && rm -r /var/log/*

#COPY code-server*.rpm /tmp
#ADD code-server-4.10.1-linux-amd64.tar.gz /tmp
#RUN wget https://github.com/coder/code-server/releases/download/v4.10.1/code-server-4.10.1-linux-amd64.tar.gz -O /tmp/code-server.tar.gz && mkdir /tmp/code-server &&  tar xf /tmp/code-server.tar.gz -C /tmp/code-server --strip-components=1
#ADD code-server-4.10.1-linux-amd64.tar.gz /tmp
#RUN zypper --non-interactive update && zypper --non-interactive install --allow-unsigned-rpm /tmp/code-server-4.10.1-amd64.rpm && zypper -n clean && rm -r /var/log/*
RUN wget https://github.com/coder/code-server/releases/download/v${ARG_CODE_SERVER_VERSION}/code-server-${ARG_CODE_SERVER_VERSION}-amd64.rpm -P /tmp

###set permission: cleaning
COPY rootfs /tmp/rootfs
RUN setfacl -R -b  /tmp/rootfs


######MAIN######
FROM registry.suse.com/bci/bci-base:${SUSE_BCI_BASE_VERSION}
# 
ARG ARG_WORKSPACE=/app/workspace
ARG ARG_PORT=8443
ARG ARG_IFBIND="0.0.0.0"
ARG ARG_VS_EXTENSIONS_GALLERY=false
ARG ARG_PASSWORD=password
ARG ARG_GIT_NAME
ARG ARG_GIT_EMAIL

#ENV ENV_PASSWORD=$ARG_PASSWORD
ENV PASSWORD=$ARG_PASSWORD
ENV ENV_VS_EXTENSIONS_GALLERY=$ARG_VS_EXTENSIONS_GALLERY
ENV ENV_PORT=$ARG_PORT
ENV ENV_IFBIND=$ARG_IFBIND
ENV ENV_WORKSPACE=$ARG_WORKSPACE
ENV ENV_GIT_NAME=$ARG_GIT_NAME
ENV ENV_GIT_EMAIL=$ARG_GIT_EMAIL

#openssh git-lfs nano man zsh curl locales
#git lfs install
RUN zypper --non-interactive update && zypper --non-interactive install git sudo && zypper -n clean && rm -r /var/log/*
RUN --mount=from=packages,src=/tmp,dst=/tmp zypper --non-interactive install --allow-unsigned-rpm /tmp/code-server*.rpm && zypper -n clean && rm -r /var/log/*

COPY --from=packages /tmp/rootfs /
RUN useradd -u 911 -m -d /app/config code && chown -R code:users /app && chown code /usr/local/bin/entrypoint.sh


ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

USER code
#VOLUME /app
WORKDIR $ENV_WORKSPACE
EXPOSE $ENV_PORT
#CMD ["/usr/bin/code-server","--bind-addr", "echo","$ENV_IFBIND"]
CMD /usr/bin/code-server --bind-addr $ENV_IFBIND:$ENV_PORT --auth password --disable-telemetry --disable-update-check $ENV_WORKSPACE




#COPY --from=packages /tmp/code-server /usr/local
#ADD code-server-4.10.1-linux-amd64.tar.gz /usr/local

#RUN chmod +x /opt/entrypoint.sh
#RUN chown code /usr/local/bin/entrypoint.sh
#--bind-addr $IFBIND --disable-telemetry --disable-update-check $WORKSPACE

#config.yaml: password, bind-addr
#not needed: --bind-addr 0.0.0.0:8443 --auth password
#CMD code-server --disable-telemetry --disable-update-check /app/workspace
