#!/bin/bash

# Download the JWT signing key and setup rotation
wget ${AUTHZ_SERVER}/v1/keys -O /etc/nginx/keys.jwk

# SED will replace the admin scope configuration correctly
sed -ie 's/ADMIN_SCOPE/'"$ADMIN_SCOPE"'/g' /etc/nginx/conf.d/default.conf

# Start php-fpm
service php7.0-fpm start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start php7.0-fpm: $status"
  exit $status
fi

# Start nginx
service nginx start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi

# Check every 60s if both nginx and php-fpm are running. If not, stop docker
while /bin/true; do
  service nginx status | grep fail
  NGINX_STATUS=$?
  service php7.0-fpm status | grep fail
  PHP_STATUS=$?
  if [ $NGINX_STATUS -ne 1 -o $PHP_STATUS -ne 1 ]; then
    echo "One of the processes has already exited."
    exit -1
  fi
  sleep 60
done
