# Laravel Docker Images

This repo contains pre-built dockerimages for Laravel.

## Using this image

Create a dockerfile in the root of your project:

```dockerfile
FROM composer:2 AS build-php

WORKDIR /var/www
COPY . ./
RUN composer install --optimize-autoloader --ignore-platform-req=php --ignore-platform-req=ext-*

FROM node:20 AS build-frontend

WORKDIR /var/www

COPY package.json ./
COPY pnpm-lock.yaml ./
COPY .npmrc ./

RUN corepack enable && \
    pnpm install

# To make tailwind purge find templates from vendor
COPY --from=build-php /var/www/vendor /var/www/vendor
COPY . ./

RUN pnpm run build && rm -rf node_modules

FROM kolaente/laravel:8.3-octane-prod

RUN apt-get install -y mariadb-client && \
  docker-php-ext-install mysqli curl exif && \
  docker-php-ext-install pdo pdo_mysql

COPY . ./
COPY --from=build-frontend /var/www/public /var/www/public
COPY --from=build-php /var/www/vendor /var/www/vendor
```

This will package the whole application as a single docker image ready to deploy.

## Using Frankenphp

The Frankenphp image does not have drivers for mysql or postgresql installed. If you need those, you'll have to install them yourself:

```dockerfile
FROM composer:2.6 AS build-php

WORKDIR /app
COPY . ./
RUN composer install --optimize-autoloader --ignore-platform-req=php --ignore-platform-req=ext-*

FROM node:20 AS build-frontend

WORKDIR /app

COPY package.json ./
COPY pnpm-lock.yaml ./
COPY .npmrc ./

RUN corepack enable && \
    pnpm install

# To make tailwind purge find templates from vendor
COPY --from=build-php /app/vendor /app/vendor
COPY . ./

RUN pnpm run build && rm -rf node_modules

FROM kolaente/laravel:8.3-octane-frankenphp

RUN apt-get update && apt-get install -y libpq-dev && \
  docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
  docker-php-ext-install pdo_pgsql pgsql

COPY . ./
COPY --from=build-frontend /app/public /app/public
COPY --from=build-php /app/vendor /app/vendor
```
