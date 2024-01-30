#!/bin/sh

set -e

setup

artisan-start /var/www/artisan

php -d variables_order=EGPCS /var/www/artisan octane:start --server=swoole --host=127.0.0.1 --port=8000 &

exec nginx -g 'daemon off;'
