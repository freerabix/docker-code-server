
#!BuildTag: docker-code-server:latest

FROM registry.suse.com/bci/bci-base:15.4

COPY entrypoint.sh /opt

ENTRYPOINT /opt/entrypoint.sh