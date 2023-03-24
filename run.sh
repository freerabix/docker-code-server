
#--no-cache 
#docker image -f prune
#docker system prune -a -f
mkdir rootfs/app/workspace
#docker build -t test .
docker run --rm -it -p 8443:8443 \
-e ENV_RUN_USER=root -e ENV_WORKSPACE=/mnt -e ENV_USER_PASSWORD=hallo -e ENV_WEB_PASSWORD=hallo \
-e ENV_GIT_NAME=robert -e ENV_GIT_EMAIL=rij@jj.de test