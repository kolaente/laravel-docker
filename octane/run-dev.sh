#!/bin/sh

set -e

setup

php -d variables_order=EGPCS /var/www/artisan octane:start --watch --host=0.0.0.0 --port=80

