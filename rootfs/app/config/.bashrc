#!/bin/bash


#source /etc/profile.d/bash_completion.sh
#export PS1="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "
export PS1="\e[1;34m[\e[1;33m\u@\e[1;32mdocker-\h\e[1;37m:\w\[\e[1;34m]\e[1;36m\\$ \e[0m"

#ALPINE_RELEASE=``

echo -e -n '\E[1;34m'
figlet -w 120 "SeCocker Code-Server"
#echo -e "\E[1;36mVersion \E[1;32m${NPM_BUILD_VERSION:-0.0.0-dev} (${NPM_BUILD_COMMIT:-dev}) ${NPM_BUILD_DATE:-0000-00-00}\E[1;36m, OpenResty \E[1;32m${OPENRESTY_VERSION:-unknown}\E[1;36m, ${ID:-alpine} \E[1;32m${RELEASE: cat /etc/alpine-release}\E[1;36m, Certbot \E[1;32m$(certbot --version)\E[0m"
echo -e "\E[1;36m Code-Server: \E[1;32m$(/opt/npm/bin/code-server -v | head -n1 | awk '{print $1;}')\E[1;36m, Alpine \E[1;32m$(cat /etc/alpine-release)\E[1;36m, Tini \E[1;32m$(tini --version | head -n1 | awk '{print $3;}')\E[1;36m, Home: \E[1;32m${HOME}\E[1;36m, Workspace: \E[1;32m${ENV_WORKSPACE}\E[1;36m   \E[0m"
echo -e -n '\E[1;34m'
#cat /built-for-arch
echo -e '\E[0m'

#/opt/npm/bin/code-server -v | head -n1 | awk '{print $1;}'
#cat /etc/alpine-release