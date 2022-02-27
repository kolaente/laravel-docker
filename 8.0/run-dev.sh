#!/bin/sh

setup

php -d variables_order=EGPCS /var/www/artisan octane:start --watch --server=swoole --host=0.0.0.0 --port=80
