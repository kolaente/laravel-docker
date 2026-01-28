#!/bin/sh

set -e

setup

artisan-start /app/artisan

HTTPS_FLAGS=""
PORT=80
HOST="0.0.0.0"
case "$APP_URL" in
    https://*)
        HTTPS_FLAGS="--https --http-redirect"
        PORT=443
        HOST="${SERVER_NAME:-localhost}"
        ;;
esac

exec php -d variables_order=EGPCS /app/artisan octane:start --server=frankenphp --host=$HOST --port=$PORT --admin-port 2019 $HTTPS_FLAGS
