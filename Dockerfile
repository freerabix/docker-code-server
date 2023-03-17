###template: https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile


FROM registry.suse.com/bci/bci-base:15.4 as packages

RUN zypper --non-interactive update && zypper --non-interactive install tar gzip xz wget acl && zypper -n clean && rm -r /var/log/*

#COPY code-server*.rpm /tmp
#ADD code-server-4.10.1-linux-amd64.tar.gz /tmp
#RUN wget https://github.com/coder/code-server/releases/download/v4.10.1/code-server-4.10.1-linux-amd64.tar.gz -O /tmp/code-server.tar.gz && mkdir /tmp/code-server &&  tar xf /tmp/code-server.tar.gz -C /tmp/code-server --strip-components=1
#ADD code-server-4.10.1-linux-amd64.tar.gz /tmp
#RUN zypper --non-interactive update && zypper --non-interactive install --allow-unsigned-rpm /tmp/code-server-4.10.1-amd64.rpm && zypper -n clean && rm -r /var/log/*
RUN wget https://github.com/coder/code-server/releases/download/v4.10.1/code-server-4.10.1-amd64.rpm -P /tmp

###set permission: cleaning
COPY rootfs /tmp/rootfs
RUN setfacl -R -b  /tmp/rootfs
RUN chown 911:root /tmp/rootfs/usr/local/bin/entrypoint.sh


######MAIN######
FROM registry.suse.com/bci/bci-base:15.4

ARG WORKSPACE=/app/workspace
ARG IFBIND="0.0.0.0:8443"
ARG GIT_NAME
ARG GIT_EMAIL
ARG VS_EXTENSIONS_GALLERY=false
ARG PASSWORD=password

ENV PASSWORD=$PASSWORD
ENV VS_EXTENSIONS_GALLERY=$VS_EXTENSIONS_GALLERY
ENV IFBIND=$IFBIND
ENV WORKSPACE=$WORKSPACE
ENV GIT_NAME=$GIT_NAME
ENV GIT_EMAIL=$GIT_EMAIL
#ENV EXTENSIONS_GALLERY='{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"}'

#openssh git-lfs nano man zsh curl locales
#git lfs install
RUN zypper --non-interactive update && zypper --non-interactive install git sudo

#todo: git name
COPY --from=packages /tmp/rootfs /
#RUN mkdir -p /app/config/.config/code-server && mkdir /app/workspace && 
RUN useradd -u 911 -m -d /app/config code && chown -R code:users /app
#COPY product.json /app/config/.config/code-server
#COPY config.yaml /app/config/.config/code-server


#ADD code-server-4.10.1-linux-amd64.tar.gz /usr/local
RUN --mount=from=packages,src=/tmp,dst=/tmp zypper --non-interactive install --allow-unsigned-rpm /tmp/code-server*.rpm && zypper -n clean && rm -r /var/log/*
#COPY --from=packages /tmp/code-server /usr/local

VOLUME /app

USER code
WORKDIR $WORKSPACE
EXPOSE 8443

#config.yaml: password, bind-addr
#not needed: --bind-addr 0.0.0.0:8443 --auth password
#CMD code-server --disable-telemetry --disable-update-check /app/workspace

#RUN chmod +x /opt/entrypoint.sh
#ENTRYPOINT /usr/local/bin/entrypoint.sh
#--bind-addr $IFBIND --disable-telemetry --disable-update-check $WORKSPACE
CMD /usr/bin/code-server
