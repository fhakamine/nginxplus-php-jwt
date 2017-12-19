# nginxplus-php-jwt


## About this image

This is a sample docker container used to test JWT with NGINX Plus.

## How to use (TL;DR)

```
git clone https://github.com/fhakamine/nginxplus-php-jwt.git
cd nginxplus-php-jwt
# To get the nginx-repo.* files, sign up for a NGINX Plus trial
cp nginx-repo.crt license
cp nginx-repo.key license
docker build -t nginx_plus .
# Sign-up for a Free Okta Developer account (https://developer.okta.com). Get an Authz Server and register an admin scope (i.e. php:admin)
docker run --name nginxplus -p 80:80 -e ADMIN_SCOPE='php:admin' -e AUTHZ_SERVER='https://ice.oktapreview.com/oauth2/123123123' nginx_plus
```

## How to use

1. Clone this repo or download its contents.
2. Register for an NGINX Plus (Trial or buy): https://www.nginx.com
3. Save the NGINX license (key and crt) under the license folder
4. Build your docker container: `docker build -t nginx_plus .`
5. Configure your Okta Tenant (get an ADMIN_SCOPE and an AUTHZ_SERVER url).
6. Run your container:
```
docker run --name nginxplus -p 80:80 -e ADMIN_SCOPE='php:admin' -e AUTHZ_SERVER='https://ice.oktapreview.com/oauth2/123123123' nginx_plus
```

*IMPORTANT: Be careful when managing your nginxplus keys! Your don't want to accidentally make them public*

## Parameters

- `AUTHZ_SERVER`: Your authorization server URL. For example: https://ice.oktapreview.com/oauth2/123usuhwuhw82

## Specs

- The container runs Nginx Plus and PHP FastCGI Process Manager (fpm).
- Container runs as http://localhost.
- You must obtain your token in an external app.
- The HTTP server contains a phpinfo.php file that shows your HEADERS.
- You can always work on your Docker/PHP/NGINX-fu to customize the default behavior.

## How to test

### Without JWT:

1. Go to http://localhost/phpinfo.php
2. Check your results (you should get an 403 - Unauthorized)

### With JWT:

1. Go to http://localhost/phpinfo.php
2. Check your results (you'll get a 200 and the headers will display info about your JWT token and claims)

## Support

This container is provided “AS IS” with no express or implied warranty for accuracy or accessibility. This container intended to demonstrate the basic integration between HTTP servers with JWT and does not represent, by any means, the recommended approach or is intended to be used in development or productions environments.
