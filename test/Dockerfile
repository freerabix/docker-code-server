

FROM alpine:3.15 as build

RUN apk update && apk add --no-cache nano bash


FROM build as build2pp

RUN apk update && apk add --no-cache clang