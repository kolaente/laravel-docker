#!/bin/sh

set -e

setup

artisan-start /app/artisan

# FRANKENPHP_HTTPS=false opts out of TLS for https APP_URLs, for setups where
# a reverse proxy terminates TLS and --http-redirect would 308-loop.
HTTPS_FLAGS=""
PORT=80
HOST="0.0.0.0"
case "$APP_URL" in
    https://*)
        if [ "$FRANKENPHP_HTTPS" != "false" ]; then
            HTTPS_FLAGS="--https --http-redirect"
            PORT=443
            HOST="${SERVER_NAME:-localhost}"
            export OCTANE_HTTPS=true
        fi
        ;;
esac

exec php -d variables_order=EGPCS /app/artisan octane:start --server=frankenphp --host=$HOST --port=$PORT --admin-port 2019 $HTTPS_FLAGS
