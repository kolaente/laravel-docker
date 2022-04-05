# Laravel Docker Images

This repo contains pre-built dockerimages for Laravel.

## Using this image

Create a dockerfile in the root of your project:

```
FROM composer:2 AS build-php

WORKDIR /var/www
COPY . ./
RUN composer install --optimize-autoloader --ignore-platform-req=php

FROM node:16 AS build-frontend

WORKDIR /var/www
COPY . ./

RUN yarn --frozen-lockfile && yarn prod && rm -rf node_modules

FROM kolaente/laravel:8.0-apache-prod # or octane or 8.1

COPY . ./
COPY --from=build-frontend /var/www/public /var/www/public
COPY --from=build-php /var/www/vendor /var/www/vendor
```

This will package the whole application as a single docker image ready to deploy.

