###template: https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile

#ARG ARG_CPU_ARCH="amd64"
ARG ARG_REGISTRY
ARG ARG_BASE_IMAGE="code-server"
ARG ARG_CODE_SERVER_VERSION="4.11.0"
ARG ARG_BASE_TAG=$ARG_CODE_SERVER_VERSION

#FROM cs as cs.cpp
FROM --platform=amd64 ${ARG_REGISTRY}${ARG_BASE_IMAGE}:${ARG_BASE_TAG}

RUN apk update && apk add --no-cache alpine-sdk clang make automake autoconf cmake pkgconf

#LABEL org.label-schema.schema-version="1.0" \
#	org.label-schema.license="nothing" \
#	org.label-schema.name="secdocker-code-server" \
#	org.label-schema.description="A secure docker container for code server" \
#	org.label-schema.url="https://github.com/freerabix/docker-code-server" \
#	org.label-schema.vcs-url="https://github.com/freerabix/docker-code-server.git" \
#	org.label-schema.cmd="docker run --rm -ti freerabix/docker-code-server"



#FROM --platform=amd64 code-server as coder-server-java
#RUN apk update && apk add --no-cache alpine-sdk

#FROM --platform=amd64 code-server as coder-server-sdk
#RUN apk update && apk add --no-cache alpine-sdk