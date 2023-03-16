

apt install acl


##remove the + permissions
setfacl -R -b ../rootfs

##change the user to code => dockerfile
#chown -R 911: ../rootfs/app

#chmod 755 env
#chmod 644 Dockerfile README.md env/file_permissions.sh
