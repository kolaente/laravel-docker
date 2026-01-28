#!/bin/sh

set -e

setup

artisan-start /app/artisan

HTTPS_FLAGS=""
PORT=80
case "$APP_URL" in
    https://*)
        HTTPS_FLAGS="--https --http-redirect"
        PORT=443
        ;;
esac

exec php -d variables_order=EGPCS /app/artisan octane:start --server=frankenphp --host=0.0.0.0 --port=$PORT --admin-port 2019 $HTTPS_FLAGS
