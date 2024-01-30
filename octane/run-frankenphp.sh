#!/bin/sh

set -e

setup

artisan-start /app/artisan

exec "php -d variables_order=EGPCS /var/www/artisan octane:start --host=0.0.0.0 --port=80 --admin-port 2019"
