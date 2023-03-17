
docker build -t test .
docker run --rm -it -e GIT_NAME=robert -e GIT_EMAIL=rij@jj.de test