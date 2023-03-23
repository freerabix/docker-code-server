
#--no-cache 
#docker image -f prune
#docker system prune -a -f
#docker build -t test .
docker run --rm -it -e ENV_USER_PASSWORD=hallo -e ENV_WEB_PASSWORD=hallo -e ENV_GIT_NAME=robert -e ENV_GIT_EMAIL=rij@jj.de test bash