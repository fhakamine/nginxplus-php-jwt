FROM debian:stretch-slim

LABEL maintainer="Frederico Hakamine <frederico.hakamine@gmail.com>"

# Install NGINX Plus
COPY license/nginx-repo.crt /etc/ssl/nginx/
COPY license/nginx-repo.key /etc/ssl/nginx/
RUN set -x \
  && apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y apt-transport-https ca-certificates gnupg1 \
  && \
  NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
  found=''; \
  for server in \
    ha.pool.sks-keyservers.net \
    hkp://keyserver.ubuntu.com:80 \
    hkp://p80.pool.sks-keyservers.net:80 \
    pgp.mit.edu \
  ; do \
    echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
    apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
  done; \
  test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
  echo "Acquire::https::plus-pkgs.nginx.com::Verify-Peer \"true\";" >> /etc/apt/apt.conf.d/90nginx \
  && echo "Acquire::https::plus-pkgs.nginx.com::Verify-Host \"true\";" >> /etc/apt/apt.conf.d/90nginx \
  && echo "Acquire::https::plus-pkgs.nginx.com::SslCert     \"/etc/ssl/nginx/nginx-repo.crt\";" >> /etc/apt/apt.conf.d/90nginx \
  && echo "Acquire::https::plus-pkgs.nginx.com::SslKey      \"/etc/ssl/nginx/nginx-repo.key\";" >> /etc/apt/apt.conf.d/90nginx \
  && printf "deb https://plus-pkgs.nginx.com/debian stretch nginx-plus\n" > /etc/apt/sources.list.d/nginx-plus.list \
  && apt-get update && apt-get install -y nginx-plus \
  && apt-get remove --purge --auto-remove -y gnupg1 \
  && rm -rf /var/lib/apt/lists/*

# Forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# INSTALL PHP
RUN apt-get update && apt-get install -y php7.0-common php7.0-cli php7.0-fpm wget
# UPDATE PHP CONFIG
RUN sed -ie 's/listen.owner = www-data/listen.owner = nginx/g' /etc/php/7.0/fpm/pool.d/www.conf
RUN service php7.0-fpm start

# COPY CONTENT TO NGINX
COPY content /usr/share/nginx/html
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# COPY BOOTSTRAP SCRIPT
COPY run.sh run.sh
RUN chmod +x run.sh

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ./run.sh
